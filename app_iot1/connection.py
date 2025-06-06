########################################################################################################################
#
#
#  	Project     	: 	Kafka Related functionality
#
#   File            :   connection.py
#
#	By              :   George Leonard ( georgelza@gmail.com )
#
#   Created     	:   28 Mar 2025
#                   :   06 June 2025    Added OpenMetrics Component/output ability.
#
#   Notes       	:
#
#######################################################################################################################

__author__      = "George Leonard"
__email__       = "georgelza@gmail.com"
__version__     = "3.2.0"
__copyright__   = "Copyright 2025, - G Leonard"


#Libraries
import sys, json
from datetime import datetime
import socket

from confluent_kafka import KafkaError, KafkaException
from confluent_kafka import Producer



def error_cb(err):
    """ The error callback is used for generic client errors. These
        errors are generally to be considered informational as the client will
        automatically try to recover from all errors, and no extra action
        is typically required by the application.
        For this example however, we terminate the application if the client
        is unable to connect to any broker (_ALL_BROKERS_DOWN) and on
        authentication errors (_AUTHENTICATION). """
    
    ('Client error: {err}'.format(
        err    = err
    ))
    
    if err.code() == KafkaError._ALL_BROKERS_DOWN or err.code() == KafkaError._AUTHENTICATION:
        # Any exception raised from this callback will be re-raised from the
        # triggering flush() or poll() call.
        raise KafkaException(err)

# end error_cb




# https://www.youtube.com/watch?v=HX0yx5YX284    
def createKafkaProducer(config_params, siteId, logger):
       
    connection          = None  # Ensure it's initialized
        
    # Core Producer Connection  
    if config_params["SECURITY_PROTOCOL"] != "PLAINTEXT" :
        producer_conf = {
            'bootstrap.servers':    config_params["BOOTSTRAP_SERVERS"],
            'sasl.mechanism':       config_params["SASL_MECHANISMS"],
            'security.protocol':    config_params["SECURITY_PROTOCOL"],
            'sasl.username':        config_params["SASL_USERNAME"],
            'sasl.password':        config_params["SASL_PASSWORD"],
            'client.id':            socket.gethostname(),
            'error_cb':             error_cb,
        }
    else:
        producer_conf = {
            "bootstrap.servers":    config_params["BOOTSTRAP_SERVERS"],
            "security.protocol":    config_params["SECURITY_PROTOCOL"],
            "sasl.mechanism":       config_params["SASL_MECHANISMS"],
            'client.id':            socket.gethostname(),
            'error_cb':             error_cb,
        }        
    # end

    try:
        # Create producer
        connection = Producer(producer_conf)
        
    except KafkaError as kerr:
        logger.error('connection.createKafkaProducer.SerializingProducer - FAILED, Err: {kerr}'.format(
            kerr=kerr
        ))
        return -1
            
    except Exception as err:
        logger.error('connection.createKafkaProducer.SerializingProducer - FAILED, Err: {err}'.format(
            err=err
        ))

        return -1  # Ensure failure is handled properly

    # end

    logger.info("Kafka Producer instantiated for: {siteId}, {connection}".format(
        siteId     = siteId,
        connection = connection
    ))
    
    logger.info("")
    
    return connection

#end createKafkaProducer


def postToKafka(connection, key, mode, payloadmsg, topic, logger):
    
    key   = str(key)
        
    if connection is None:
        logger.error("Kafka producer is None, skipping produce.")
        
    else:
    
        try:
            if mode == 0:
                mode = "PostOne"
                                        
                value = json.dumps(payloadmsg)

                connection.produce(
                    topic       = topic,
                    key         = key,
                    value       = value,
                )

                connection.poll(0)
            
            else:
                mode = "PostMany"
                
                for val in payloadmsg:     
                                    
                    value = json.dumps(val)

                    connection.produce(
                        topic       = topic,    
                        key         = key,
                        value       = value,
                    )
                                    
                connection.flush()

            #end if
            return 1
        
        except Exception as err:
            logger.error('connection.postTokafka.produce - mode {mode} - FAILED, Err: {err}'.format(
                mode = mode,
                err  = err
            ))
            return 0
            
        # end try
        
#end post_to_kafka


def delivery_callback(err, msg, logger):
    """Delivery report callback called (from flush()) on successful or failed delivery of the message."""
    if err is not None:
        logger.error('Failed to deliver message: {}'.format(err.str()))
        
    else:
        #pass
        logger.info('Produced to: {} [{}] @ {}'.format(msg.topic(), msg.partition(), msg.offset()))

    #end if
    
#end acked

""" 
Lets create to write json strings to a file.
This will be json structured flattened into a single line.
"""
def createFileConnection(filename, siteId, logger):
    
    file = None

    try:
        if filename != "": 
            file = open(filename, 'a')  # Open the file in append mode
            
            if file != None:
                logger.debug('connection.createFileConnection - Filename {filename} - {siteId} OPENED'.format(
                    siteId   = siteId,
                    filename = filename
                ))   
                return file

            else:
                return -1
            
            #end if            
        # end if                                 
                       
    except IOError as err:
        logger.critical('connection.createFileConnection - {siteId} - FAILED Err: {err} '.format(
            siteId = siteId,
            err    = err
        ))
        
        return -1
    
    # end try
# end createFileConnection

def writeToFile(file, siteId, mode, payload, logger):

    try:

        if file:        
            if mode == 0:
                mode = "writeOne"
                # Convert the payload dictionary to a JSON string
                file.write(payload + '\n')  # Add a newline at the end

            else:

                mode = "writeMany"
                for record in payload:
                    # Convert each payload to a JSON string and write it to the file
                    file.write(record + '\n')  # Write each payload on a new line
                    
            # end if
                        
            return 1
   
    except IOError as err:
        logger.error('connection.writeToFile - {siteId} - mode {mode} - FAILED, Err: {err}'.format(
            siteId = siteId,
            mode   = mode,
            err    = err
        ))
        
        return -1

    # end try
# end writeToFile


def closeFileConnection(file, siteId, logger):
    
    if file:
        try:            
            file.close()
            logger.debug('connection.closeFileConnection - {siteId} CLOSED'.format(
                siteId = siteId
            ))
            
        except IOError as err:
            logger.error('connection.closeFileConnection - {siteId} - FAILED, Err: {err}'.format(
                siteId = siteId,
                err    = err
            ))
                        
        # end try
    # endif
# end close_file