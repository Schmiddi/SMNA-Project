package model;

import java.util.Date;

public class BlogEntry {
	// The following three are partially redundant
	private String authorName;
	private String authorCountry;
	
	private String blogID;		// authorName/blogName
	private String blogEntryID; // authorName/blogName/hashcode
		
	private String country;
	private String city;
	private String state;
	
	private Date date;
	
	private String content;

	public BlogEntry(){
		state = "";
	}

	public String getAuthorName() {
		return authorName;
	}

	public String getBlogID() {
		return blogID;
	}

	public String getBlogEntryID() {
		return blogEntryID;
	}

	public String getCountry() {
		return country;
	}

	public String getCity() {
		return city;
	}

	public String getState() {
		return state;
	}

	public Date getDate() {
		return date;
	}

	public void setAuthorName(String authorName) {
		this.authorName = authorName;
	}

	public void setBlogID(String blogID) {
		this.blogID = blogID;
	}

	public void setBlogEntryID(String blogEntryID) {
		this.blogEntryID = blogEntryID;
	}

	public void setCountry(String country) {
		this.country = country;
	}

	public void setCity(String city) {
		this.city = city;
	}

	public void setState(String state) {
		this.state = state;
	}

	public void setDate(Date date) {
		this.date = date;
	}

	public String getAuthorCountry() {
		return authorCountry;
	}

	public void setAuthorCountry(String authorCountry) {
		this.authorCountry = authorCountry;
	}

	public String getContent() {
		return content;
	}

	public void setContent(String content) {
		this.content = content;
	}

	@Override
	public String toString() {
		return "BlogEntry [authorName=" + authorName + ", authorCountry=" + authorCountry + ", blogID=" + blogID
				+ ", blogEntryID=" + blogEntryID + ", country=" + country + ", city=" + city + ", state=" + state
				+ ", date=" + date + "]";
	}
	
	
	
}
