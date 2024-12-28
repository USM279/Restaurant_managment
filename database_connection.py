import psycopg2

def connect():
    try:
        connection = psycopg2.connect(
            database="your_database_name",
            user="postgres",
            password="your_database_password",
            host="localhost",
            port="5432"
        )
        print("Database connected successfully!")
        return connection
    except Exception as e:
        print("Error connecting to database:", e)
        return None
