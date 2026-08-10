import json
import redis
from flask import Flask, request, jsonify, render_template

app = Flask(__name__)

redis_client = redis.Redis(
    host="redis",
    port=6379,
    db=0,
    password="passwd123",
    decode_responses=True
)

REDIS_KEY = "names"

def save_name(first, last):
    redis_client.rpush(REDIS_KEY, json.dumps({"first_name": first, "last_name": last}))

def get_all_names():
    raw_items = redis_client.lrange(REDIS_KEY, 0, -1)
    return [json.loads(item) for item in raw_items]

def reset_names():
    redis_client.delete(REDIS_KEY)


@app.route("/")
def index():
    return render_template("index.html")


@app.route("/api/save", methods=["POST"])
def api_save():
    data = request.get_json()
    first = data.get("first_name", "")
    last = data.get("last_name", "")
    save_name(first, last)
    return jsonify({"ok": True})


@app.route("/api/get")
def api_get():
    names = get_all_names()
    return jsonify({"names": names})


@app.route("/api/reset", methods=["POST"])
def api_reset():
    reset_names()
    return jsonify({"ok": True})


if __name__ == "__main__":
    app.run(host="0.0.0.0", debug=True, port=5001)