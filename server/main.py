from flask import Flask, request, render_template, jsonify
from flask_limiter import Limiter
from flask_limiter.util import get_remote_address
from flask_cors import CORS, cross_origin
from web3 import Web3
import json

CONTRACT = "0x5FbDB2315678afecb367f032d93F642f64180aa3"
PRIVATE_KEY = "0xac0974bec39a17e36ba4a6b4d238ff944bacb478cbed5efcae784d7bf4f2ff80"
RPC_URL = "http://127.0.0.1:8545"

ABI = [
    {
        "inputs": [
            {"internalType": "address", "name": "user", "type": "address"}
        ],
        "name": "slash",
        "outputs": [],
        "stateMutability": "nonpayable",
        "type": "function"
    }
]

W = Web3(Web3.HTTPProvider(RPC_URL))
if not W.is_connected():
    print("Error: Failed to connect to the RPC node.")
    exit()

C = W.eth.contract(address=W.to_checksum_address(CONTRACT), abi=ABI)

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

    if not user or not W.is_address(user):
        return jsonify({"error": "Invalid or missing 'user' parameter."}), 400

    user = W.to_checksum_address(user)
    nonce = W.eth.get_transaction_count(W.to_checksum_address(W.eth.account.from_key(PRIVATE_KEY).address))
    
    txn = C.functions.slash(user).build_transaction({
        'chainId': W.eth.chain_id,
        'gas': 200000,
        'gasPrice': W.to_wei('5', 'gwei'),
        'nonce': nonce,
    })

    signed_txn = W.eth.account.sign_transaction(txn, private_key=PRIVATE_KEY)
    try:
        tx_hash = W.eth.send_raw_transaction(signed_txn.rawTransaction)
        return jsonify({"tx_hash": tx_hash.hex()}), 200000
    except Exception as e:
        return jsonify({"error": str(e)}), 500
