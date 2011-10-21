from flask import Flask, render_template, send_file

app = Flask(__name__, static_folder='media')

@app.route("/")
def index():
    return send_file("media/index.html")

@app.route("/db.json")
def db():
    return send_file("data/db.json")

@app.route("/world/<path:path>")
def world(path):
    return send_file("data/world/%s.html" % path)

if __name__ == "__main__":
    import os, sys
    port = int(os.environ.get("PORT", 5000))
    if '-d' in sys.argv:
        app.debug = True
    app.run(port=port) #host='0.0.0.0',
