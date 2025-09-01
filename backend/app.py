from flask import Flask, jsonify
from flask_cors import CORS
import mysql.connector

app = Flask(__name__)
CORS(app)

# Connect to RDS
conn = mysql.connector.connect(
    host="noalb3tier-mysql.czoa0myssruj.ap-south-1.rds.amazonaws.com",
    user="admin",
    password="SuperSecret123!",   # Replace with actual password
    database="appdb"
)
cursor = conn.cursor()

@app.route("/health")
def health():
    return jsonify({"status": "ok"})

@app.route("/users")
def get_users():
    cursor.execute("SELECT id, name, email FROM users;")
    users = [{"id": row[0], "name": row[1], "email": row[2]} for row in cursor.fetchall()]
    return jsonify(users)

if __name__ == "__main__":
    app.run(host="0.0.0.0", port=5000)




