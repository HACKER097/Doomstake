from flask import Flask, request, render_template, jsonify
from flask_limiter import Limiter
from flask_limiter.util import get_remote_address
from flask_cors import CORS, cross_origin
import json

CONTRACT = "0xjdkdjdjfjf"

app = Flask(__name__)
CORS(app, support_credentials=True)
limiter = Limiter(
    get_remote_address,
    default_limits=["100 per minute"],
    app=app
)

@app.route("/api/slash", ["GET"])
def slash():
    user = request.args.get("user")

