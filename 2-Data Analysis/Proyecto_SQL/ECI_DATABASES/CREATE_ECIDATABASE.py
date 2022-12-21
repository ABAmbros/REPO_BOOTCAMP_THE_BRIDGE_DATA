import sqlite3 as sql


def createDB():
    conn = sql.connect("AAP_eci_database.sql")
    conn.commit()
    conn.close()

if __name__ == "__main__":
    createDB()