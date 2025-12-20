import psycopg2

conn = psycopg2.connect(
    dbname="upi_fraud",
    user="postgres",
    password="nami",
    host="localhost",
    port="5432"
)

def get_cursor():
    return conn.cursor()

