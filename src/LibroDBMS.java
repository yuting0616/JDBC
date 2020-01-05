import java.io.File;
import java.io.FileNotFoundException;
import java.sql.*;
import java.util.Scanner;

public class LibroDBMS {
    private final String url = "jdbc:postgresql://cmpstudb-01.cmp.uea.ac.uk:5432/fvt15dda?currentSchema=Libro_Database";
    private final String user = "fvt15dda";
    private final String password = "U4x6x9e5";

    private final Connection connection;
    private final Statement statement;

    public LibroDBMS() throws SQLException, ClassNotFoundException {

        this.connection = DriverManager.getConnection(url, user, password);
        System.out.println("1");
        this.statement = this.connection.createStatement();
        this.statement.execute("SET search_path to Libro_Database;");
    }

    public void insertBook(String bno, String title, String author, String category, String price) throws SQLException {
        this.statement.execute("SET search_path to Libro_Database;");
        String query = "INSERT INTO book VALUES (?,?,?,?,?);";
        PreparedStatement preparedStatement = this.connection.prepareStatement(query);
        preparedStatement.setInt(1, Integer.parseInt(bno));
        preparedStatement.setString(2, title);
        preparedStatement.setString(3, author);
        preparedStatement.setString(4, category);
        preparedStatement.setDouble(5, Double.parseDouble(price));
        preparedStatement.executeUpdate();
        System.out.println("=================Transaction A: One new book has been inserted!=================");
    }

    public void deleteBook(String bno) throws SQLException {
        String query = "DELETE FROM book WHERE bno = ?;";
        PreparedStatement preparedStatement = this.connection.prepareStatement(query);
        preparedStatement.setInt(1, Integer.parseInt(bno));
        preparedStatement.executeUpdate();
        System.out.println("=================Transaction B: One book has been deleted!=================");
    }

    public void insertCustomer(String cno, String name, String address) throws SQLException {
        String query = "INSERT INTO customer VALUES (?, ? ,?);";
        PreparedStatement preparedStatement = this.connection.prepareStatement(query);
        preparedStatement.setInt(1, Integer.parseInt(cno));
        preparedStatement.setString(2, name);
        preparedStatement.setString(3, address);
        preparedStatement.executeUpdate();
        System.out.println("=================Transaction C: One new customer has been inserted!=================");
    }

    public void deleteCustomer(String cno) throws SQLException {
        String query = "DELETE FROM customer WHERE cno = ?;";
        PreparedStatement preparedStatement = this.connection.prepareStatement(query);
        preparedStatement.setInt(1, Integer.parseInt(cno));
        preparedStatement.executeUpdate();
        System.out.println("=================Transaction D: One customer has been deleted!=================");
    }

    public void placeOrder(String cno, String bno, String qty) throws SQLException {
        String query = "INSERT INTO bookOrder VALUES (?, ?, ?);";
        PreparedStatement preparedStatement = this.connection.prepareStatement(query);
        preparedStatement.setInt(1, Integer.parseInt(cno));
        preparedStatement.setInt(2, Integer.parseInt(bno));
        preparedStatement.setInt(3, Integer.parseInt(qty));
        preparedStatement.executeUpdate();
        System.out.println("=================Transaction E: One new order has been created!=================");
    }

    public void recordPayment(String cno, String payment) throws SQLException {
        String query = "UPDATE customer SET balance = balance - ? WHERE cno = ?;";
        PreparedStatement preparedStatement = this.connection.prepareStatement(query);
        preparedStatement.setDouble(1, Double.parseDouble(payment));
        preparedStatement.setInt(2, Integer.parseInt(cno));
        preparedStatement.executeUpdate();
        System.out.println("=================Transaction F: A payment has been made=================");
    }

    public void findCustomer(String keyword) throws SQLException {
        String query = "SELECT book.title, customer.name, customer.address FROM bookOrder\n" +
                "INNER JOIN book on bookOrder.bno = book.bno\n" +
                "INNER JOIN customer on bookOrder.cno = customer.cno\n" +
                "WHERE title LIKE ?\n" +
                "ORDER BY title ASC, name ASC;";
        PreparedStatement preparedStatement = this.connection.prepareStatement(query);
        preparedStatement.setString(1, "%" + keyword + "%");
        ResultSet resultSet = preparedStatement.executeQuery();
        System.out.println("=================Transaction G: Customers are shown below=================");
        while (resultSet.next()==true) {
            String title = resultSet.getString("title");
            String name = resultSet.getString("name");
            String address = resultSet.getString("address");
            System.out.println(title + ", " + name + ", " + address);
        }
    }

    public void findBooks(String cno) throws SQLException {
        String query = "SELECT customer.name, book.bno, book.title, book.author FROM bookOrder\n" +
                "LEFT JOIN book on bookOrder.bno = book.bno\n" +
                "LEFT JOIN customer on bookOrder.cno = customer.cno\n" +
                "WHERE bookOrder.cno = ?\n" +
                "ORDER BY bookOrder.bno;";
        PreparedStatement preparedStatement = this.connection.prepareStatement(query);
        preparedStatement.setInt(1, Integer.parseInt(cno));
        ResultSet resultSet = preparedStatement.executeQuery();
        System.out.println("=================Transaction H: Books are shown below=================");
        while (resultSet.next()) {
            String name = resultSet.getString("name");
            String bno = resultSet.getString("bno");
            String title = resultSet.getString("title");
            String author = resultSet.getString("author");
            System.out.println(name + ", " + bno + ", " + title + ", " + author);
        }
    }

    public void bookReport() throws SQLException {
        String query = "SELECT category, SUM(sales) AS num_of_books, sum(price * sales) AS total_sales_value FROM book\n" +
                "GROUP BY category;";
        PreparedStatement preparedStatement = this.connection.prepareStatement(query);
        ResultSet resultSet = preparedStatement.executeQuery();
        System.out.println("=================Transaction I: Book Report are shown below=================");
        while (resultSet.next()) {
            String category = resultSet.getString("category");
            String num_of_books = resultSet.getString("num_of_books");
            String total_sales_value = resultSet.getString("total_sales_value");
            System.out.println(category + ", " + num_of_books + ", " + total_sales_value);
        }
    }

    public void customerReport() throws SQLException {
        String query = "SELECT customer.cno, customer.name, SUM(bookorder.qty) FROM customer\n" +
                "INNER JOIN bookOrder on customer.cno = bookOrder.cno\n" +
                "GROUP BY customer.cno\n" +
                "ORDER BY customer.cno;";
        PreparedStatement preparedStatement = this.connection.prepareStatement(query);
        ResultSet resultSet = preparedStatement.executeQuery();
        System.out.println("=================Transaction J: Customer Report are shown below=================");
        while (resultSet.next()) {
            String cno = resultSet.getString("cno");
            String name = resultSet.getString("name");
            String sum = resultSet.getString("sum");
            System.out.println(cno + ", " + name + ", " + sum);
        }
    }

    public void dailySales() throws SQLException {
        String query = "SELECT SUM(bookOrder.qty) FROM bookOrder\n" +
                "WHERE DATE(bookOrder.orderTime) = (SELECT current_date);";
        PreparedStatement preparedStatement = this.connection.prepareStatement(query);
        ResultSet resultSet = preparedStatement.executeQuery();
        System.out.println("=================Transaction K: Daily Sales are shown below=================");
        while (resultSet.next()) {
            String sum = resultSet.getString("sum");
            System.out.println(sum);
        }
    }

    public void endOfRequest() throws SQLException {
        String query = "DROP TABLE book         CASCADE;\n" +
                "DROP TABLE customer     CASCADE;\n" +
                "DROP TABLE bookOrder\tCASCADE;\n" +
                "DROP SCHEMA Libro_Database CASCADE;";
        PreparedStatement preparedStatement = this.connection.prepareStatement(query);
        preparedStatement.executeUpdate();
        System.out.println("=================Transaction X: End Drop Tables=================");
    }


    public static void main(String[] args) throws SQLException, FileNotFoundException, ClassNotFoundException {
        LibroDBMS libroDBMS = new LibroDBMS();
        File file = new File("./SampleInput.txt");
        Scanner scanner = new Scanner(file);
        while (scanner.hasNext()) {
            char transaction = scanner.nextLine().charAt(0);
            switch (transaction) {
                case 'A':
                    String bno = scanner.nextLine();
                    String title = scanner.nextLine();
                    String author = scanner.nextLine();
                    String category = scanner.nextLine();
                    String price = scanner.nextLine();
                    libroDBMS.insertBook(bno, title, author, category, price);
                    break;
                case 'B':
                    libroDBMS.deleteBook(scanner.nextLine());
                    break;
                case 'C':
                    libroDBMS.insertCustomer(scanner.nextLine(), scanner.nextLine(), scanner.nextLine());
                    break;
                case 'D':
                    libroDBMS.deleteCustomer(scanner.nextLine());
                    break;
                case 'E':
                    libroDBMS.placeOrder(scanner.nextLine(), scanner.nextLine(), scanner.nextLine());
                    break;
                case 'F':
                    libroDBMS.recordPayment(scanner.nextLine(), scanner.nextLine());
                    break;
                case 'G':
                    libroDBMS.findCustomer(scanner.nextLine());
                    break;
                case 'H':
                    libroDBMS.findBooks(scanner.nextLine());
                    break;
                case 'I':
                    libroDBMS.bookReport();
                    break;
                case 'J':
                    libroDBMS.customerReport();
                    break;
                case 'K':
                    libroDBMS.dailySales();
                    break;
                case 'X':
                    libroDBMS.endOfRequest();
                    break;
            }
        }
    }
}
