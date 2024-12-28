import tkinter as tk
from tkinter import ttk, messagebox
from database_connection import connect

class DatabaseApp:
    def __init__(self, root):
        self.root = root
        self.root.title("Database Management App")
        self.root.geometry("1000x600")

        # السماح للنافذة بالتوسع
        self.root.grid_rowconfigure(1, weight=8)
        self.root.grid_rowconfigure(2, weight=1)
        self.root.grid_columnconfigure(0, weight=1)
        self.root.grid_columnconfigure(1, weight=1)

        # اختيار الجدول
        tk.Label(root, text="Select Table:").grid(row=0, column=0, padx=10, pady=10, sticky="nw")
        self.table_selection = ttk.Combobox(root, values=[
            "customer", "staff", "role", "menuitem", "customerorder",
            "orderitem", "payment", "diningtable", "ordertable",
            "stock", "orderdiscount", "staffactionlog", "staffrole"
        ])
        self.table_selection.grid(row=0, column=1, padx=10, pady=10, sticky="ne")
        self.table_selection.bind("<<ComboboxSelected>>", self.load_columns)

        # مربع البحث
        search_frame = tk.Frame(root)
        search_frame.grid(row=0, column=2, padx=10, pady=10, sticky="ne")
        tk.Label(search_frame, text="Search by ID:").pack(side=tk.LEFT, padx=5)
        self.search_entry = tk.Entry(search_frame)
        self.search_entry.pack(side=tk.LEFT, padx=5)
        tk.Button(search_frame, text="Search", command=self.search_by_id).pack(side=tk.LEFT, padx=5)

        # إدخالات البيانات
        self.entries = {}
        self.data_frame = tk.Frame(root)
        self.data_frame.grid(row=1, column=0, columnspan=2, sticky="nsew")

        # جدول العرض
        self.tree = ttk.Treeview(root, columns=[], show="headings")
        self.tree.grid(row=2, column=0, columnspan=3, sticky="nsew")
        self.tree.bind("<<TreeviewSelect>>", self.on_row_select)  # حدث لتعبئة البيانات عند النقر

        # أزرار العمليات
        button_frame = tk.Frame(root)
        button_frame.grid(row=3, column=0, columnspan=3, pady=10)
        tk.Button(button_frame, text="List", command=self.list_data).grid(row=0, column=0, padx=10)
        tk.Button(button_frame, text="Insert", command=self.insert_data).grid(row=0, column=1, padx=10)
        tk.Button(button_frame, text="Update", command=self.update_data).grid(row=0, column=2, padx=10)
        tk.Button(button_frame, text="Delete", command=self.delete_data).grid(row=0, column=3, padx=10)

    def load_columns(self, event):
        """تحميل أسماء الأعمدة وإنشاء إدخالات البيانات"""
        table = self.table_selection.get().lower()
        if not table:
            messagebox.showwarning("Warning", "Please select a table!")
            return

        self.clear_entries()
        self.tree.delete(*self.tree.get_children())

        connection = connect()
        cursor = connection.cursor()
        cursor.execute(f'SELECT * FROM "{table}" LIMIT 0')  # جلب أسماء الأعمدة فقط
        column_names = [desc[0] for desc in cursor.description]
        connection.close()

        self.tree["columns"] = column_names
        for col in column_names:
            self.tree.heading(col, text=col)
            self.tree.column(col, width=100)

        for idx, col in enumerate(column_names):
            tk.Label(self.data_frame, text=col).grid(row=idx, column=0, padx=5, pady=5, sticky="w")
            entry = tk.Entry(self.data_frame)
            entry.grid(row=idx, column=1, padx=5, pady=5, sticky="e")
            self.entries[col] = entry

    def list_data(self):
        """عرض جميع البيانات من الجدول"""
        table = self.table_selection.get().lower()
        if not table:
            messagebox.showwarning("Warning", "Please select a table!")
            return

        self.tree.delete(*self.tree.get_children())  # تنظيف الجدول قبل إعادة العرض
        connection = connect()
        cursor = connection.cursor()
        try:
            cursor.execute(f'SELECT * FROM "{table}"')
            rows = cursor.fetchall()
            for row in rows:
                self.tree.insert("", "end", values=row)
        except Exception as e:
            messagebox.showerror("Error", f"Failed to load data: {e}")
        finally:
            connection.close()

    def search_by_id(self):
        """البحث حسب ID"""
        table = self.table_selection.get().lower()
        if not table:
            messagebox.showwarning("Warning", "Please select a table!")
            return

        search_value = self.search_entry.get().strip()
        if not search_value:
            messagebox.showwarning("Warning", "Please enter an ID to search!")
            return

        self.tree.delete(*self.tree.get_children())  # تنظيف الجدول قبل إعادة عرض النتائج
        connection = connect()
        cursor = connection.cursor()
        try:
            # البحث فقط عن طريق العمود الأول (ID)
            column_name = self.tree["columns"][0]
            cursor.execute(f'SELECT * FROM "{table}" WHERE CAST({column_name} AS TEXT) LIKE %s', (f"%{search_value}%",))
            rows = cursor.fetchall()
            for row in rows:
                self.tree.insert("", "end", values=row)  # عرض النتائج
        except Exception as e:
            messagebox.showerror("Error", f"Failed to search data: {e}")
        finally:
            connection.close()

    def insert_data(self):
        """إضافة بيانات جديدة"""
        table = self.table_selection.get().lower()
        columns = ", ".join(self.entries.keys())
        values = ", ".join(["%s"] * len(self.entries))
        data = [entry.get() for entry in self.entries.values()]

        try:
            connection = connect()
            cursor = connection.cursor()
            cursor.execute(f'INSERT INTO "{table}" ({columns}) VALUES ({values})', data)
            connection.commit()
            connection.close()
            messagebox.showinfo("Success", "Data inserted successfully!")
            self.list_data()
        except Exception as e:
            messagebox.showerror("Error", f"Failed to insert data: {e}")

    def update_data(self):
        """تحديث بيانات موجودة"""
        table = self.table_selection.get().lower()
        primary_key = list(self.entries.keys())[0]
        key_value = self.entries[primary_key].get()
        updates = ", ".join([f"{col} = %s" for col in self.entries.keys()])
        data = [entry.get() for entry in self.entries.values()] + [key_value]

        try:
            connection = connect()
            cursor = connection.cursor()
            cursor.execute(f'UPDATE "{table}" SET {updates} WHERE {primary_key} = %s', data)
            connection.commit()
            connection.close()
            messagebox.showinfo("Success", "Data updated successfully!")
            self.list_data()
        except Exception as e:
            messagebox.showerror("Error", f"Failed to update data: {e}")

    def delete_data(self):
        """حذف بيانات"""
        table = self.table_selection.get().lower()
        primary_key = list(self.entries.keys())[0]
        key_value = self.entries[primary_key].get()

        try:
            connection = connect()
            cursor = connection.cursor()
            cursor.execute(f'DELETE FROM "{table}" WHERE {primary_key} = %s', (key_value,))
            connection.commit()
            connection.close()
            messagebox.showinfo("Success", "Data deleted successfully!")
            self.list_data()
        except Exception as e:
            messagebox.showerror("Error", f"Failed to delete data: {e}")

    def on_row_select(self, event):
        """تعبئة البيانات عند اختيار صف"""
        selected_item = self.tree.selection()
        if selected_item:
            item_values = self.tree.item(selected_item, 'values')
            for i, key in enumerate(self.entries.keys()):
                self.entries[key].delete(0, tk.END)
                self.entries[key].insert(0, item_values[i])

    def clear_entries(self):
        """تنظيف الإدخالات"""
        for widget in self.data_frame.winfo_children():
            widget.destroy()
        self.entries.clear()

if __name__ == "__main__":
    root = tk.Tk()
    app = DatabaseApp(root)
    root.mainloop()
