from google.cloud import bigquery



def query_stackoverflow():
    #client = bigquery.Client()
    client = bigquery.Client.from_service_account_json('creds.json')
    query_job = client.query(
        """
        SELECT * FROM `schema.table` LIMIT 10
        """
    )

    results = query_job.result()  # Waits for job to complete.

    for row in results:
        print("{} : {} views".format(row.id, row.event_label))


def insertData():
    # Insert values in a table
    client = bigquery.Client.from_service_account_json('creds.json')
    dataset_id = '919205757093'
    table_id = 'test'
    table_ref = client.dataset(dataset_id).table(table_id)
    table = client.get_table(table_ref)
    rows_to_insert = [
            (u'1', 'name1'),
            (u'2', 'name2'),
            ]
    errors = client.insert_rows(table, rows_to_insert)
    print(errors)
if __name__ == "__main__":
    query_stackoverflow()
    #insertData()
