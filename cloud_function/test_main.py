import unittest, requests

class TestGetFlights(unittest.TestCase):

    def test_get_flights_no_filter(self):
        # Trigger the Cloud Function
        # Send the GET request and capture the response
        response = requests.get("https://southamerica-west1-latam-challenge-421420.cloudfunctions.net/get_flights", params={})

        # Assert successful response and at least 1 row returned
        self.assertEqual(response.status_code, 200)

        num_rows = 0
        # Get the response data as JSON
        data = response.json()
        # Check if data is a list (assuming rows are in an array)
        if isinstance(data, list):
            # Get the number of rows
            num_rows = len(data)
        
        # Assert at least 1 row returned
        self.assertGreaterEqual(num_rows, 1)


    def test_get_flights_with_filter(self):
        # Trigger the Cloud Function
        # Send the GET request and capture the response
        response = requests.get("https://southamerica-west1-latam-challenge-421420.cloudfunctions.net/get_flights?departure_city=Chicago", params={})

        # Assert successful response and at least 1 row returned
        self.assertEqual(response.status_code, 200)

        # Get the response data as JSON
        data = response.json()
        # Assert the departure city is Chicago (the filter was applied)
        self.assertEqual(data[0]["Departure_City"], "Chicago")

if __name__ == "__main__":
  unittest.main()
