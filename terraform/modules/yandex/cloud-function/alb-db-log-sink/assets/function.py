import os
import logging
import mysql.connector
from mysql.connector import errorcode
import json

logger = logging.getLogger()
logger.setLevel(logging.INFO)
verboseLogging = eval(os.environ['VERBOSE_LOG'])
if verboseLogging:
    logger.info('Loading handler function')

def handler(event, context):
    statusCode = 500

    if verboseLogging:
        logger.info(event)
        logger.info(context)

    connection_string = (
        "host='{db_hostname}' port='{db_port}' dbname='{db_name}' "
        "user='{db_user}' password='{db_password}'"
    ).format(
        db_hostname=os.environ['DB_HOSTNAME'],
        db_port=os.environ['DB_PORT'],
        db_name=os.environ['DB_NAME'],
        db_user=os.environ['DB_USER'],
        db_password=os.environ['DB_PASSWORD']
    )

    if verboseLogging:
        logger.info(f'Connecting: {connection_string}')

    conn = mysql.connector.connect(connection_string)
    cursor = conn.cursor()

    messages = event['messages'][0]['details']['messages']

    for message in messages:
        alb_message = json.loads(message['message'])
        alb_message['table_name'] = 'load_balancer_requests'
        insert_statement = (
            'INSERT INTO {table_name} ' 
            '(type, "time", http_status, backend_ip, request_time) ' 
            'VALUES(\'{type}\', timestamptz \'{time}\', \'{http_status}\', ' 
            '\'{backend_ip}\', {request_processing_times[request_time]});'
        ).format(**alb_message)

        if verboseLogging:     
            logger.info(f'{insert_statement}')
        try:
            cursor.execute(insert_statement)
            statusCode = 200
        except Exception as error:
            logger.error(error)

        conn.commit()

    cursor.close()
    conn.close()

    return {
        'statusCode': statusCode,
        'headers': {
            'Content-Type': 'text/plain'
        }
    }