from airflow import DAG
from airflow.utils.dates import days_ago
from airflow.operators.docker_operator import DockerOperator
from docker.types import Mount

from airflow.providers.http.operators.http import SimpleHttpOperator
from airflow.providers.http.sensors.http import HttpSensor
from airflow.models import Variable
import json

default_args = {
    'owner': 'carlos_figueroa',
    'start_date': days_ago(1),
}

AIRBYTE_CONNECTION_ID = Variable.get("CONNECTION_ID")
API_KEY = f'Bearer {Variable.get("CLOUD_API_TOKEN")}'

with DAG(
        'github_to_bq_dag',
        default_args=default_args,
        schedule_interval=None,
        catchup=False
    ) as dag:

    trigger_sync = SimpleHttpOperator(
        method="POST",
        task_id='start_airbyte_sync',
        http_conn_id='airbyte-api-cloud',
        headers={
            "Content-Type":"application/json",
            "User-Agent": "fake-useragent",
            "Accept": "application/json",
            "Authorization": API_KEY},
        endpoint=f'/v1/jobs',
        data=json.dumps({"connectionId": AIRBYTE_CONNECTION_ID, "jobType": "sync"}),
        do_xcom_push=True,
        response_filter=lambda response: response.json()['jobId'],
        log_response=True,
    )

    wait_for_sync_to_complete = HttpSensor(
        method='GET',
        task_id='wait_for_airbyte_sync',
        http_conn_id='airbyte-api-cloud',
        headers={
            "Content-Type":"application/json",
            "User-Agent": "fake-useragent",
            "Accept": "application/json",
            "Authorization": API_KEY},
        endpoint='/v1/jobs/{}'.format("{{ task_instance.xcom_pull(task_ids='start_airbyte_sync') }}"),
        poke_interval=5,
        response_check=lambda response: json.loads(response.text)['status'] == "succeeded"
    )

    run_dbt_task = DockerOperator(
        task_id='run_dbt_models',
        image='custom_dbt_image',
        api_version='auto',
        docker_url='unix://var/run/docker.sock', 
        command='sh -c "cd /dbtlearn && dbt run"',
        mounts=[Mount(source='/Users/carlos/Work/Interviews/pensionbee/airflow-dbt-bigquery-docker/dbtlearn',target='/dbtlearn',type='bind')],
        network_mode='container:dbt',  
        dag=dag
    )

    trigger_sync >> wait_for_sync_to_complete >> run_dbt_task