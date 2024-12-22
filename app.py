from flask import Flask, render_template, request, redirect, url_for
import mysql.connector
from config import DB_CONFIG

app = Flask(__name__)

# Database connection function
def get_db_connection():
    return mysql.connector.connect(
        host=DB_CONFIG['HOST'],
        user=DB_CONFIG['USER'],
        password=DB_CONFIG['PASSWORD'],
        database=DB_CONFIG['DATABASE']
    )

# Route to display the list of all cases
@app.route('/')
def index():
    """Display the list of all cases."""
    connection = get_db_connection()
    cursor = connection.cursor(dictionary=True)
    cursor.execute("SELECT * FROM Cases")
    cases = cursor.fetchall()
    connection.close()
    return render_template('index.html', cases=cases)

# Route to view the details of a single case
@app.route('/case/<int:case_id>')
def case_detail(case_id):
    """Display the details of a single case."""
    connection = get_db_connection()
    cursor = connection.cursor(dictionary=True)
    
    # Get case details and client name by joining Cases with Clients
    cursor.execute("""
        SELECT Cases.*, Clients.name AS client_name
        FROM Cases
        JOIN Clients ON Cases.client_id = Clients.client_id
        WHERE Cases.case_id = %s
    """, (case_id,))
    
    case = cursor.fetchone()
    
    if not case:
        connection.close()
        return "Case not found!", 404

    # Get payments for the case
    cursor.execute("SELECT * FROM Payments WHERE case_id = %s", (case_id,))
    payments = cursor.fetchall()

    # Get lawyer assignments for the case
    cursor.execute("SELECT * FROM CaseAssignments WHERE case_id = %s", (case_id,))
    assignments = cursor.fetchall()
    
    connection.close()
    
    return render_template('case_detail.html', case=case, payments=payments, assignments=assignments)

# Route to render the form to add a new case
@app.route('/add_case', methods=['GET', 'POST'])
def add_case():
    """Allow the user to add a new case."""
    if request.method == 'POST':
        case_name = request.form['case_name']
        case_description = request.form['case_description']
        client_id = request.form['client_id']
        
        # Check if client exists
        connection = get_db_connection()
        cursor = connection.cursor()
        cursor.execute("SELECT * FROM Clients WHERE client_id = %s", (client_id,))
        client = cursor.fetchone()
        
        if not client:
            connection.close()
            return "Client not found!", 404
        
        cursor.execute("INSERT INTO Cases (case_name, case_description, client_id) VALUES (%s, %s, %s)", 
                       (case_name, case_description, client_id))
        connection.commit()
        connection.close()
        return redirect(url_for('index'))
    
    return render_template('add_case.html')

# Route to render the form to add a payment to a specific case
@app.route('/add_payment_form/<int:case_id>', methods=['GET'])
def add_payment_form(case_id):
    """Render the payment form for a specific case."""
    connection = get_db_connection()
    cursor = connection.cursor(dictionary=True)
    
    # Get case details for the title
    cursor.execute("SELECT * FROM Cases WHERE case_id = %s", (case_id,))
    case = cursor.fetchone()
    connection.close()

    return render_template('add_payment.html', case=case)

# Route to add a payment for a specific case
@app.route('/add_payment/<int:case_id>', methods=['POST'])
def add_payment(case_id):
    """Allow the user to add a payment to a case."""
    amount = request.form['amount']
    payment_date = request.form['payment_date']
    
    # Insert the payment record into the Payments table
    connection = get_db_connection()
    cursor = connection.cursor()
    cursor.execute("INSERT INTO Payments (case_id, amount, payment_date) VALUES (%s, %s, %s)", 
                   (case_id, amount, payment_date))
    connection.commit()
    connection.close()
    
    return redirect(url_for('case_detail', case_id=case_id))

# Start the Flask app
if __name__ == '__main__':
    app.run(debug=True)
