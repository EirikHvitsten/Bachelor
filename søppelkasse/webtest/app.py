"""
Flask: Using Cookies
"""

from flask import Flask, render_template, request, redirect, url_for, make_response, jsonify

app = Flask(__name__)
app.debug = True


@app.route("/")
def index():
    return "Hello World"

@app.route("/data", methods=["POST"])
def data():
    ting = request.get_json()
    print(ting)
    print("hei")
    return redirect("/")



if __name__ == "__main__":
    app.run()