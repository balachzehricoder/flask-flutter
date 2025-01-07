from flask import Flask, request, jsonify
import pyshorteners

app = Flask(__name__)

# Initialize URL shortener
shortener = pyshorteners.Shortener()

@app.route('/shortner', methods=['POST'])
def shorten_url():
    data = request.get_json()
    original_url = data.get("url")
    
    if not original_url:
        return jsonify({"error": "No URL provided"}), 400
    
    try:
        # Use pyshorteners to shorten the URL
        short_url = shortener.tinyurl.short(original_url)
        return jsonify({"short_url": short_url}), 200
    except Exception as e:
        return jsonify({"error": str(e)}), 500

if __name__ == "__main__":
    app.run(host='0.0.0.0', port=5000)

