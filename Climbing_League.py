import tkinter as tk
from tkinter import messagebox
import mysql.connector

# Database connection
def connect_db():
    return mysql.connector.connect(
        host="localhost",
        user="root",
        password="",        #put your password for root here
        database="RockClimbingDatabase"
    )

# Function to add climb score
def add_climb_score():
    mem_num = entry_mem_num.get()
    climb_id = entry_climb_id.get()
    if mem_num and climb_id:
        try:
            conn = connect_db()
            cursor = conn.cursor()
            cursor.execute(f"SELECT Add_climb({mem_num}, {climb_id}) AS updated_score")
            result = cursor.fetchone()
            conn.commit()
            conn.close()
            if result and result[0] != -2:
                messagebox.showinfo("Success", f"Updated Current Score: {result[0]}")
            else:
                messagebox.showerror("Error", "Invalid Member Number or Climb ID.")
        except Exception as e:
            messagebox.showerror("Error", str(e))
    else:
        messagebox.showerror("Error", "Please enter both Member Number and Climb ID.")

# Function to add boulder score
def add_boulder_score():
    mem_num = entry_mem_num_boulder.get()
    boulder_id = entry_boulder_id.get()
    if mem_num and boulder_id:
        try:
            conn = connect_db()
            cursor = conn.cursor()
            cursor.execute(f"SELECT Add_boulder({mem_num}, {boulder_id}) AS updated_score")
            result = cursor.fetchone()
            conn.commit()
            conn.close()
            if result and result[0] != -2:
                messagebox.showinfo("Success", f"Updated Current Score: {result[0]}")
            else:
                messagebox.showerror("Error", "Invalid Member Number or Boulder ID.")
        except Exception as e:
            messagebox.showerror("Error", str(e))
    else:
        messagebox.showerror("Error", "Please enter both Member Number and Boulder ID.")

# Function to calculate and update score
def sum_score():
    mem_num = entry_mem_num_score.get()
    if mem_num:
        try:
            conn = connect_db()
            cursor = conn.cursor()
            cursor.execute(f"SELECT Sum_score( {mem_num}) AS team_score")
            result = cursor.fetchone()
            conn.commit()
            conn.close()
            if result:
                messagebox.showinfo("Success", f"Updated Team Score: {result[0]}")
            else:
                messagebox.showerror("Error", "Error calculating team score.")
        except Exception as e:
            messagebox.showerror("Error", str(e))
    else:
        messagebox.showerror("Error", "Please enter Gym ID, Team Number, and Member Number.")

# Create Tkinter window
root = tk.Tk()
root.title("Rock Climbing League")

# Add Climb Score Section
tk.Label(root, text="Add Climb Score").grid(row=0, column=0, columnspan=2)
tk.Label(root, text="Member Number:").grid(row=1, column=0)
entry_mem_num = tk.Entry(root)
entry_mem_num.grid(row=1, column=1)
tk.Label(root, text="Climb ID:").grid(row=2, column=0)
entry_climb_id = tk.Entry(root)
entry_climb_id.grid(row=2, column=1)
tk.Button(root, text="Add Climb", command=add_climb_score).grid(row=3, column=0, columnspan=2)

# Add Boulder Score Section
tk.Label(root, text="Add Boulder Score").grid(row=4, column=0, columnspan=2)
tk.Label(root, text="Member Number:").grid(row=5, column=0)
entry_mem_num_boulder = tk.Entry(root)
entry_mem_num_boulder.grid(row=5, column=1)
tk.Label(root, text="Boulder ID:").grid(row=6, column=0)
entry_boulder_id = tk.Entry(root)
entry_boulder_id.grid(row=6, column=1)
tk.Button(root, text="Add Boulder", command=add_boulder_score).grid(row=7, column=0, columnspan=2)

# Calculate and Update Score Section
tk.Label(root, text="Calculate and Update Score").grid(row=8, column=0, columnspan=2)

tk.Label(root, text="Member Number:").grid(row=11, column=0)
entry_mem_num_score = tk.Entry(root)
entry_mem_num_score.grid(row=11, column=1)
tk.Button(root, text="Calculate Score", command=sum_score).grid(row=12, column=0, columnspan=2)

# Run the Tkinter event loop
root.mainloop()
