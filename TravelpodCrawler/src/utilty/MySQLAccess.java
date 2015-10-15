package utilty;

import java.sql.Connection;
import java.sql.DriverManager;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.sql.Statement;
import java.util.Calendar;
import java.util.Date;

import model.BlogEntry;

public class MySQLAccess {
	private static MySQLAccess instance;
	
	public static MySQLAccess getInstance(){
		if(MySQLAccess.instance == null){
			MySQLAccess.instance = new MySQLAccess();
		}
		return MySQLAccess.instance;
	}
	
	private Connection connect = null;
	private Statement statement = null;
	private PreparedStatement preparedStatement = null;
	private ResultSet resultSet = null;

	public MySQLAccess() {
		try {
			// This will load the MySQL driver, each DB has its own driver
			Class.forName("com.mysql.jdbc.Driver");
			// Setup the connection with the DB
			connect = DriverManager.getConnection("jdbc:mysql://localhost/smna?" + "user=root");
			// Statements allow to issue SQL queries to the database
			statement = connect.createStatement();
		} catch (SQLException e) {
			e.printStackTrace();
		} catch (ClassNotFoundException e1) {
			// TODO Auto-generated catch block
			e1.printStackTrace();
		}
	}
	
	/**
	 * Writes a blog entry into the mySQL database
	 * TODO: test it!!
	 * @param entry
	 * @throws SQLException
	 */
	public void writeBlogEntry(BlogEntry entry) throws SQLException{
		// PreparedStatements can use variables and are more efficient
		preparedStatement = connect.prepareStatement("insert into  smna.travelpod values (?, ?, ?, ?, ?, ?, ?, ?, ?, default)");
		// "myuser, webpage, datum, summery, COMMENTS from feedback.comments");
		// Parameters start with 1
		preparedStatement.setString(1, entry.getBlogEntryID());
		preparedStatement.setString(2, entry.getAuthorName());
		preparedStatement.setString(3, entry.getAuthorCountry());
		preparedStatement.setString(4, entry.getBlogID());
		preparedStatement.setString(5, entry.getCountry());
		preparedStatement.setString(6, entry.getCity());
		preparedStatement.setString(7, entry.getState());
		preparedStatement.setDate(8,  new java.sql.Date(entry.getDate().getTime()));
		preparedStatement.setString(9, entry.getContent());
		preparedStatement.executeUpdate();
	}

	public void readDataBase() throws Exception {
		try {

			// Statements allow to issue SQL queries to the database
			statement = connect.createStatement();
			// Result set get the result of the SQL query
			//resultSet = statement.executeQuery("select * from smna.test");

			writeResultSet(resultSet);

			// PreparedStatements can use variables and are more efficient
			preparedStatement = connect.prepareStatement("insert into  smna.test values (default, ?, ?, ?, ?)");
			// "myuser, webpage, datum, summery, COMMENTS from feedback.comments");
			// Parameters start with 1
			preparedStatement.setString(1, "britney");
			preparedStatement.setString(2, "USA");

			Calendar cal = Calendar.getInstance();
			cal.set(Calendar.DAY_OF_MONTH, 11);
			cal.set(Calendar.MONTH, 9 - 1);
			cal.set(Calendar.YEAR, 2015);

			Date date = cal.getTime();

			System.out.println(date);
			preparedStatement.setDate(3, new java.sql.Date(date.getTime()));
			preparedStatement.setString(4, "content");
			preparedStatement.executeUpdate();

			/*
			 * preparedStatement = connect
			 * .prepareStatement("SELECT myuser, webpage, datum, summery, COMMENTS from feedback.comments"); resultSet =
			 * preparedStatement.executeQuery(); writeResultSet(resultSet);
			 * 
			 * // Remove again the insert comment preparedStatement = connect
			 * .prepareStatement("delete from feedback.comments where myuser= ? ; "); preparedStatement.setString(1,
			 * "Test"); preparedStatement.executeUpdate();
			 * 
			 * resultSet = statement .executeQuery("select * from feedback.comments"); writeMetaData(resultSet);
			 */
		} catch (Exception e) {
			throw e;
		} finally {
			close();
		}

	}

	private void writeResultSet(ResultSet resultSet) throws SQLException {
		// ResultSet is initially before the first data set
		while (resultSet.next()) {
			// It is possible to get the columns via name
			// also possible to get the columns via the column number
			// which starts at 1
			// e.g. resultSet.getSTring(2);
			int id = resultSet.getInt("id");
			String website = resultSet.getString("author");
			String summery = resultSet.getString("country");
			Date date = resultSet.getDate("date");
			String comment = resultSet.getString("content");
			System.out.println("Id: " + id);
			System.out.println("Author: " + website);
			System.out.println("Country: " + summery);
			System.out.println("Date: " + date);
			System.out.println("content: " + comment);
		}
	}

	// You need to close the resultSet
	public void close() {
		try {
			if (resultSet != null) {
				resultSet.close();
			}

			if (statement != null) {
				statement.close();
			}

			if (connect != null) {
				connect.close();
			}
		} catch (Exception e) {

		}
	}

}
