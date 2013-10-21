package org.velobg.JoinSofiaAgkImage;

import java.io.ByteArrayOutputStream;
import java.io.PrintStream;
import java.nio.charset.Charset;

public class StringPrintStream extends PrintStream {

	public StringPrintStream() {
		super(new ByteArrayOutputStream());
	}
	
	public String toString() {
		return new String(((ByteArrayOutputStream) out).toByteArray(), Charset.forName("UTF-8"));
	}
	
	public byte[] toByteArray() {
		return ((ByteArrayOutputStream) out).toByteArray();
	}
}
