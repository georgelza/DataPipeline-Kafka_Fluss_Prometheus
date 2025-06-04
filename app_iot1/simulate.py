
#######################################################################################################################
#
#
#  	Project     	    : 	TimeSeries Data generation via Python Application 
#
#   File                :   simulate.py
#
#   Description         :   
#
#   Original Created   	:   22 November 2024
#   Modified            :   12 April 2025
#
#   Changelog           :   Modified from original from previous blog that posted to Mongo and 2nd Previus posted to Kafka
#                       :   to now to post to
#
#   JSON Viewer         :   https://jsonviewer.stack.hu
#
#   Notes               :   Python Logging Package: 
#                       :   https://docs.python.org/3/library/logging.html
#                       :   https://realpython.com/python-logging/
#
########################################################################################################################

__author__      = "George Leonard"
__email__       = "georgelza@gmail.com"
__version__     = "3.2.0"
__copyright__   = "Copyright 2025, - G Leonard"


import utils
import connection
import time, random, sys
from datetime import datetime, timedelta, timezone
import random
from time import perf_counter

# Function to check if the current time is within the specified time range for the site
# Business/operational hours or 24 hour site
def is_within_time_range(start_time_str, end_time_str, current_time=None):
    
    # Convert the string representations of start_time and end_time to time objects
    start_time  = datetime.strptime(start_time_str, "%H:%M").time()
    end_time    = datetime.strptime(end_time_str, "%H:%M").time()

    # just make sure we're not comparing against Null.
    if current_time is None:
        current_time = datetime.now().time()  # Get only the time part
        
    else:
        current_time = current_time.time()  # Ensure current_time is a time object

    # end if
    
    # Check if the current time is within the specified time range
    if start_time <= end_time:       # Return true... we're suppose to work/generate data between these times
        return start_time <= current_time <= end_time 
    
    else: # Check if end_time is less than start_time, meaning the time range spans midnight
        return current_time >= start_time or current_time <= end_time

    # end if
    return False    # Should never get here, but just in case

# end is_within_time_range


# Helper to convert local time with timezone to UTC
def convert_to_utc(local_time_with_tz):
    return local_time_with_tz.astimezone(timezone.utc)

# Example function to generate payloads with timezone in the timestamp
def generate_payload(logger, site, device, sensor, current_time, time_zone_offset, config_params):

   # Adjust the timestamp to include the site's local timezone offset
    offset_hours, offset_minutes = map(int, time_zone_offset.split(":"))
    tz_offset                    = timezone(timedelta(hours=offset_hours, minutes=offset_minutes))
    local_time_with_tz           = current_time.replace(tzinfo=tz_offset)
    ts_human                     = local_time_with_tz.strftime("%Y-%m-%dT%H:%M:%S.%f")
    
    if site["data_persistence"] == 1:
        # If output to file then we passin a text formated date/time string.
        ts = ts_human

    else:   
        utc_time = convert_to_utc(local_time_with_tz) # Convert to UTC        
        ts = int(utc_time.timestamp() * 1000) # Convert to timestamp (milliseconds)

    #end 
    
    # Get last_value, default to sensor['mean'] if not set (for the very first iteration)
    last_val = sensor.get('last_value', sensor['mean'])
    
    measurement = progress_value(logger, sensor, current_time, device["sfd_start_time"], device["sfd_end_time"], device["stabilityFactor"], last_val)

    payload = {
        "ts": ts,  # Timestamp now includes the correct timezone
        "metadata": {
            "siteId":   site["siteId"],
            "deviceId": device["deviceId"],
            "sensorId": sensor["sensorId"],
            "unit":     sensor["unit"],
        },
        "measurement": measurement
    }

    if config_params["TSHUMAN"] == 1:
        payload["metadata"]["ts_human"] = ts_human
        
    if config_params["STRUCTMOD"] == 1:
        payload["metadata"]["location"] = site["location"]
        
    if config_params["DEVICETYPE"] == 1:
        payload["metadata"]["deviceType"] = device["deviceType"]
        
    return payload

# end generate_payload

"""
Generate a sensor value, 
Scaling sd based on stability_factor if the current time is within device start_time and end_time.
If start_time and end_time are not provided for the device, no scaling is applied.
"""
def progress_value(logger, sensor, current_time_local, sfd_start_time_str, sfd_end_time_str, stabilityFactor, last_value):
    # Extract sensor parameters
    mean             = sensor['mean']
    sd               = sensor['sd']
    min_value        = sensor['min_range']
    max_value        = sensor['max_range']
    deviation_weight = sensor.get('deviation_weight', 5) # Default to 5 if not specified

    # Convert SFD time strings to time objects
    sfd_start_time          = datetime.strptime(sfd_start_time_str, "%H:%M").time()
    sfd_end_time            = datetime.strptime(sfd_end_time_str, "%H:%M").time()
    current_time_local_time = current_time_local.time()

    # --- Step 1: Calculate daily progressive adjustment (applies all day) ---
    current_minutes_from_midnight = current_time_local_time.hour * 60 + current_time_local_time.minute
    total_minutes_in_day          = 24 * 60
    midday_minutes                = 12 * 60

    # Calculate a daily trend factor that ranges from -1 (midnight) to 1 (midday) and back to -1 (next midnight).
    # This creates a progressive upward and downward movement throughout the day.
    if current_minutes_from_midnight <= midday_minutes:
        # First half of the day (00:00 to 12:00): factor goes linearly from -1 to 1
        daily_trend_factor = (current_minutes_from_midnight / midday_minutes) * 2 - 1
        
    else:
        # Second half of the day (12:00 to 24:00): factor goes linearly from 1 to -1
        daily_trend_factor = ((total_minutes_in_day - current_minutes_from_midnight) / midday_minutes) * 2 - 1

    #end if
    
    # Define the magnitude of the daily swing for the base mean
    daily_swing_magnitude = (max_value - min_value) * 0.1 
    
    # Calculate the base mean for the day, incorporating the progressive trend
    # This base_mean will oscillate around the sensor's original mean.
    base_mean = mean + daily_trend_factor * daily_swing_magnitude
    
    # Ensure the base_mean stays within reasonable bounds (e.g., min_range and max_range)
    base_mean = max(min_value, min(base_mean, max_value))

    # Initialize effective_sd with sensor's original sd
    effective_sd = sd

    # Determine if current time is within the SFD window
    is_in_sfd_time = False
    if sfd_start_time <= sfd_end_time:
        is_in_sfd_time = (sfd_start_time <= current_time_local_time <= sfd_end_time)
        
    else: # SFD time range spans across midnight (e.g., 22:00 to 02:00)
        is_in_sfd_time = (current_time_local_time >= sfd_start_time or current_time_local_time <= sfd_end_time)

    #end if
    
    
    # --- Step 2: Calculate new_value based on last_value and current context ---
    new_value = last_value # Start from the previous value
    random_step = 0.0

    if is_in_sfd_time:
        # --- "Go Mad" progressive behavior during SFD ---
        # Determine the target extreme based on deviation_weight
        target_value = base_mean # Default target if deviation_weight is exactly 5

        if deviation_weight > 5:
            target_value = max_value # Push towards max
            
        elif deviation_weight < 5:
            target_value = min_value # Push towards min

        #end if
        
        # Calculate the growth rate for SFD. This rate is aggressive and influenced by stabilityFactor
        # Lower stabilityFactor and deviation_weight further from 5 lead to faster growth.
        base_sfd_rate = 0.05 # Minimum progressive step rate in SFD (e.g., 5% of distance to target)
        
        # Influence from stabilityFactor: lower stability means higher rate
        stability_influence = (100 - stabilityFactor) / 100.0 # 0 (stable) to 1 (unstable)
        
        # Influence from deviation_weight: further from 5 means higher rate
        deviation_influence = abs(deviation_weight - 5) / 5.0 # 0 (at 5) to 1 (at 0 or 10)

        # Combine influences to get the aggressive pull factor
        # This factor makes the value move rapidly towards the target_value
        sfd_pull_factor = base_sfd_rate + (0.95 - base_sfd_rate) * max(stability_influence, deviation_influence)
        
        # Cap the pull factor to ensure it doesn't jump too much in one step
        sfd_pull_factor = min(sfd_pull_factor, 0.5) # Max 50% of remaining distance per step

        # Calculate the primary directional step towards the target
        directional_step = (target_value - new_value) * sfd_pull_factor

        # Add some controlled random noise on top of the directional step.
        # The noise magnitude can still be influenced by the original SD and stability.
        noise_magnitude_sfd = sd * (1 + (100 - stabilityFactor) / 200.0) # Modest SD escalation for noise
        noise_magnitude_sfd = min(noise_magnitude_sfd, (max_value - min_value) * 0.02) # Cap noise at 2% of range
        random_noise_sfd    = random.uniform(-noise_magnitude_sfd, noise_magnitude_sfd)
        random_step         = directional_step + random_noise_sfd

        # Ensure the step is capped to prevent single-step jumps that go directly to min/max
        # This maintains the "progressive" nature even when "going mad".
        max_sfd_step_cap = (max_value - min_value) * 0.15 # Max 15% of total range per step
        random_step      = max(-max_sfd_step_cap, min(random_step, max_sfd_step_cap))

    else: # Outside SFD time (all other times)
        # --- Linear growth reading to reading behavior (outside SFD) ---
        # The goal is to move progressively towards base_mean, with small, directionally-biased fluctuations,
        # influenced by stabilityFactor.

        # Calculate how much to scale the standard deviation for the random step.
        # When stabilityFactor is 100, the effective_sd_non_sfd will be very small (e.g., 5% of original sd).
        # When stabilityFactor is 0, the effective_sd_non_sfd will be larger (e.g., 100% of original sd).
        min_noise_multiplier = 0.05 
        weight_for_sd        = min_noise_multiplier + (1.0 - min_noise_multiplier) * ((100 - stabilityFactor) / 100.0)
        effective_sd_non_sfd = sd * weight_for_sd

        # Generate a random step based on the calculated effective_sd_non_sfd
        random_step_from_sd  = random.uniform(-effective_sd_non_sfd, effective_sd_non_sfd)

        # Calculate the strength of the pull towards the base_mean.
        # When stabilityFactor is 100, pull strongly (0.05). When stabilityFactor is 0, pull very weakly (0.001).
        pull_factor = 0.05 * (stabilityFactor / 100.0) 
        if pull_factor < 0.001: # Ensure a minimal pull to prevent complete drift
            pull_factor = 0.001

        #end if
        
        # Calculate the step that pulls the value towards the base_mean
        step_towards_mean = (base_mean - last_value) * pull_factor

        # Combine the random step and the pull towards the mean
        random_step = random_step_from_sd + step_towards_mean

        # Apply an overall cap on the total step to maintain a sense of linear progression,
        # even when growing away from the mean due to lower stability.
        max_total_step = (max_value - min_value) * 0.01 # Max 1% change of total range per step
        random_step    = max(-max_total_step, min(random_step, max_total_step))
        
    #end if
    
    
    # Calculate the new value based on the previous value and the determined random_step
    new_value = last_value + random_step

    # Clamp the new value to be within the sensor's defined min and max range.
    # This is the ultimate safeguard to ensure values never go out of bounds.
    new_value = round(max(min_value, min(new_value, max_value)), 4)
    
    logger.debug(" {sensorId}, {current_time_local_time}, {min_range},  {max_range}  {sd}  {mean} {new_value}".format(
        sensorId                = sensor["sensorId"],
        current_time_local_time = current_time_local_time,
        min_range               = min_value,
        max_range               = max_value,
        sd                      = sd,
        mean                    = mean,
        new_value               = new_value
    ))
    
    return new_value

# end progress_value


""" 
Function to run simulation for a specific site, this is main body of the generator
"""
def run_simulation(site, current_time, config_params):
    
    topic       = config_params["TOPIC"]
    mode        = config_params["MODE"]
    flush_size  = config_params["BATCH_SIZE"]
    
    if flush_size > 0:
        mode        = 1         # save Many
        payloadset  = []
        
    else:
        mode    = 0          # save One
        payload = None
        
    #end if
    
    # Create new site specific logger's
    logger = utils.logger(config_params["LOGGINGFILE"] + "_" + str(site["siteId"]) + ".log", site["console_debuglevel"], site["file_debuglevel"])
        
    logger.info("simulate.run_simulation - Starting Simulation")
    
    logger.debug('simulate.run_simulation - Printing Complete site seed record for site')
    
    utils.pp_json(site, logger)
    
    site_time_zone = site["time_zone"]
        
    # Parse the start_datetime and begin simulation
    if "historic_data_start_datetime" in site:
        oldest_time = datetime.strptime(site["historic_data_start_datetime"], "%Y-%m-%dT%H:%M")
        
    else:
        oldest_time = current_time

    # Determine time range for simulation, if we specify this then the site/device/sensor only create measurements
    # ... within the specified time range, otherwise we run the simulation for the full day range/24 hours.

    run_limited_time = False        
    if "operational_start_time" in site and "operational_end_time" in site:
        run_limited_time = True
        
        operational_start_time  = site["operational_start_time"]
        operational_end_time    = site["operational_end_time"]
        
    # end if

                  
    connection_saver    = connection.createKafkaProducer(config_params, site["siteId"], logger)      
    if connection_saver == -1:
        logger.critical(f"SiteId: {str(site["siteId"])} - run_simulation.connection.createKafkaProducer Failed, exiting.")
        sys.exit(1)
                                
    # end if
    
        
    historical_record_counter   = 0             # Keep track of how many historical records are created.
    current_record_counter      = 0             # Keep track of how many current records was created.
    total_record_counter        = 0             # sum of above 2
    batch_flush_counter         = 0             # batch incrementer/counter.
            
    # Historical phase
    if "historic_data_start_datetime" in site and site["historic_data_start_datetime"]:

        step1starttime  = datetime.now()
        step1start      = perf_counter()
            
        logger.info("simulate.run_simulation - Execute Historical Phase,   Starting from {historic_data_start_datetime}".format(
            historic_data_start_datetime = site["historic_data_start_datetime"]
        ))
    
        
        while oldest_time < current_time:
            oldest_time += timedelta(milliseconds=site["sleeptime"])    
 
            # chec if we're specified a start end day for day
            if run_limited_time:
                # yes, so now check if current time is inside/outside, if outsice then we skip via continue call
                if not is_within_time_range(operational_start_time, operational_end_time, oldest_time):
                    continue
                
                    print("Skipping record outside time range, this should never happen/print")
                # end if
            # end if
            
            for device in site["devices"]:
                for sensor in device["sensors"]:
                    
                    payload = generate_payload(logger, site, device, sensor, oldest_time, site_time_zone, config_params)
                    
                    sensor["last_value"] = payload["measurement"]

                    historical_record_counter   += 1
                    total_record_counter        += 1
                    
                    # batch posting
                    if mode == 1:             
                        batch_flush_counter += 1
                        payloadset.append(payload)
 
                        if batch_flush_counter == flush_size:
                            result              = connection.postToKafka(connection_saver, site["siteId"], mode, payloadset, topic, logger)
                            batch_flush_counter = 0
                            payloadset          = []

                    #single record posting.
                    else:
                       result  = connection.postToKafka(connection_saver, site["siteId"], mode, payload, topic, logger)
                        
                    #end if                   
                # end for
            # end for
            
            oldest_time += timedelta(milliseconds=site["sleeptime"])

        # end while
        
        logger.info("simulate.run_simulation - COMPLETED Historical Phase, Started from {historic_data_start_datetime}, Created {historical_record_counter} records".format(
            historic_data_start_datetime = site["historic_data_start_datetime"],
            historical_record_counter    = historical_record_counter
        ))     

        step1endtime = datetime.now()
        step1end     = perf_counter()
        step1time    = step1end - step1start  
        histrate     = str( round(historical_record_counter/step1time, 2))

    # end Historical phase
    
    
    # Current phase  
    
    current_record_counter  = 0
    batch_flush_counter     = 0
    payloadset              = []
    if site["reccap"] > 0:
         
        step2starttime  = datetime.now()
        step2start      = perf_counter()
        oldest_time     = datetime.now()

        logger.info("simulate.run_simulation - Execute Current Phase")
        
        for loop in range(site["reccap"]):
            current_loop_time = oldest_time + timedelta(milliseconds=site["sleeptime"] * loop)

            if run_limited_time:
                if not is_within_time_range(operational_start_time, operational_end_time, current_loop_time):
                    continue
                
                    print("Skipping record outside time range, this should never happen/print")
                # end if
            # end if
            
            for device in site["devices"]:
                for sensor in device["sensors"]:
    
                    payload = generate_payload(site, device, sensor, current_loop_time, site_time_zone, config_params)

                    sensor["last_value"] = payload["measurement"]

                    current_record_counter  += 1
                    total_record_counter    += 1
                    
                    # batch posting
                    if mode == 1:                                 
                        batch_flush_counter += 1
                        payloadset.append(payload)
 
                        if batch_flush_counter == flush_size:
                            result              = connection.postToKafka(connection_saver, site["siteId"], mode, payloadset, topic, logger)
                            batch_flush_counter = 0
                            payloadset          = []

                    #single record posting.
                    else:
                        result  = connection.postToKafka(connection_saver, site["siteId"], mode, payload, topic, logger)

                    #end if     
                # end for
            # end for
            time.sleep(site["sleeptime"] / 1000)  # Convert milliseconds to seconds

        # end for
     
        
        # Post last batch of records in our payload variable to our connection store
        if mode == 1:   
            result  = connection.postToKafka(connection_saver, site["siteId"], mode, payloadset, topic, logger)
                
        # end if
        
        step2endtime = datetime.now()
        step2end     = perf_counter()
        step2time    = step2end - step2start  
        currate      = str( round(current_record_counter/step2time, 2))
    # end if    


    # Historical phase stats
    if "historic_data_start_datetime" in site and site["historic_data_start_datetime"]:
        logger.info("simulate.run_simulation - Historical Record Process Stats - St: {start}, Et: {end}, Rt: {runtime}, Recs: {historical_record_counter} docs, Rate: {histrate} docs/s".format(
            start                     = str(step1starttime.strftime("%Y-%m-%d %H:%M:%S.%f")),
            end                       = str(step1endtime.strftime("%Y-%m-%d %H:%M:%S.%f")),
            runtime                   = str(round(step1time, 4)),
            historical_record_counter = historical_record_counter,
            histrate                  = histrate
        ))
    # end if
    
    # Current phase stats
    if site["reccap"] > 0: 
        logger.info("simulate.run_simulation - Current Record Process Stats    - St: {start}, Et: {end}, Rt: {runtime}, Recs: {current_record_counter} docs,    Rate: {currate}  docs/s".format(
            start                  = str(step2starttime.strftime("%Y-%m-%d %H:%M:%S.%f")),
            end                    = str(step2endtime.strftime("%Y-%m-%d %H:%M:%S.%f")),
            runtime                = str(round(step2time, 4)),
            current_record_counter = current_record_counter,
            currate                = currate
        ))
    # end if
    
    # Final stats
    logger.info("simulate.run_simulation - COMPLETED Simulation       - Records: {historical_record_counter} + {current_record_counter} = {total_record_counter} records".format(
        historical_record_counter = historical_record_counter,
        current_record_counter    = current_record_counter,
        total_record_counter      = total_record_counter
    ))

    sys.exit(0)
# end run_simulation