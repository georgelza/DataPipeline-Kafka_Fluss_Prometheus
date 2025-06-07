## Backfilling Prometheus Data

See [backfilling-from-openmetrics-format](https://prometheus.io/docs/prometheus/latest/storage/#backfilling-from-openmetrics-format).

This following commands needs to be executed inside your prometheus container.

Note this means your /backfill and /backfill-data directories need to me added to the prometheus service in your docker compose as volumes or direct added as volumes if you running prometheus as a stand alone docker container.

cd /backfill
promtool tsdb create-blocks-from openmetrics historical_101.prom /backfill-data/

systemctl start prometheus

cp -r ./backfill-data/* /var/lib/prometheus/data/

systemctl stop prometheus