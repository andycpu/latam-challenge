import functions_framework
from google.cloud import bigquery
from flask import jsonify

@functions_framework.http
def get_flights(request):

    """HTTP Cloud Function.
    Args:
        (optional) departure_city
    Returns:
        A list of flights in json format
    """

    # process parameter
    request_args = request.args
    if request_args and 'departure_city' in request_args:
        departure_city = request_args['departure_city']
    else:
        departure_city = ''

    # default query (including all departure cities)
    query = """
    SELECT *
    FROM `latam-challenge-421420.latam_ds.flights`
    """
    # query for filtering by departure city
    if len(departure_city) > 0:
        query = """
        SELECT *
        FROM `latam-challenge-421420.latam_ds.flights`
        WHERE Departure_City = '""" + departure_city + """'
        """

    # Authenticate with Gogle Cloud Platform
    client = bigquery.Client()

    # Execute query
    query_job = client.query(query)
    results = query_job.result()  # Wait for query to complete

    # Format results
    rows = [dict(row) for row in results]
    return jsonify(rows)