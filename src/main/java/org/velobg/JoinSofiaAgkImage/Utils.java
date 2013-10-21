package org.velobg.JoinSofiaAgkImage;

import java.awt.Color;
import java.awt.Component;
import java.awt.Container;
import java.awt.Dimension;
import java.awt.Toolkit;
import java.io.ByteArrayOutputStream;
import java.io.IOException;
import java.io.InputStream;
import java.io.OutputStream;
import java.util.ArrayList;

import javax.swing.BorderFactory;
import javax.swing.JComponent;
import javax.swing.Spring;
import javax.swing.SpringLayout;

class Utils {
	public static byte[] loadStream(InputStream is) throws IOException {
		ByteArrayOutputStream os = new ByteArrayOutputStream();
		copyStream(is, os);
		is.close();
		return os.toByteArray();
	}

	public static void copyStream(InputStream is, OutputStream os) throws IOException {
		byte buf[] = new byte[256];
		int len;
		while ((len = is.read(buf)) >= 0) {
			os.write(buf, 0, len);
		}
	}

	/**
	 * Aligns all the components of <code>parent</code> in a grid with
	 * <code>columns</code>. Each component in a cell is as wide/high as the
	 * maximum preferred width/height of the components in that cell, except for
	 * the cells in row <code>springRow</code> and column <code>springCol</code>
	 * wich are made "elastic" to in order the grid to fit the parent window.
	 * 
	 * @param parent
	 *            the parent container which elements need to be put in a grid
	 * @param columns
	 *            number of columns
	 * @param springRow
	 *            number of "elastic" row
	 * @param springCol
	 *            number of "elastic" column
	 * @param insetX
	 *            horizontal inset of the grid
	 * @param insetY
	 *            vertical inset of the grid
	 * @param xPad
	 *            horizontal padding between cells
	 * @param yPad
	 *            vertical padding between cells
	 */
	public static void makeSpringGrid(Container parent, int columns, int springRow, int springCol,
			int insetX, int insetY, int xPad, int yPad) {
		SpringLayout layout;
		try {
			layout = (SpringLayout) parent.getLayout();
		} catch (ClassCastException exc) {
			System.err.println("The first argument to makeGrid must use SpringLayout.");
			return;
		}
		Component components[] = parent.getComponents();
		int maxRow = (components.length - 1) / columns;

		Spring pad;
		Component c2;
		String c2name;
		Spring c2spring;
		ArrayList<Spring> sizes;
		
		// WIDTH
		pad = Spring.constant(xPad);
		c2 = parent;
		c2name = SpringLayout.WEST;
		c2spring = Spring.constant(insetX);
		Spring totalSizeX = c2spring;
		sizes = new ArrayList<Spring>();
		
		for (int col = 0; col < columns; col++) {
			Spring width = Spring.constant(0);
			for (int i = col; i < components.length; i += columns) {
				Component c = components[i];
				SpringLayout.Constraints cons = layout.getConstraints(c);
				width = Spring.max(width, cons.getWidth());
			}
			sizes.add(width);
			totalSizeX = Spring.sum(totalSizeX, c2spring);
			totalSizeX = Spring.sum(totalSizeX, width);
			c2spring = pad;
		}

		c2spring = Spring.constant(insetX);
		for (int col = 0; col < columns; col++) {
			Spring width = sizes.get(col);

			Component c = null;
			for (int i = col; i < components.length; i += columns) {
				c = components[i];
				SpringLayout.Constraints cons = layout.getConstraints(c);
				if (col != springCol) {
					cons.setWidth(width);
				}
				if (col <= springCol) {
					layout.putConstraint(SpringLayout.WEST, c, c2spring, c2name, c2);
				}
			}
			c2 = c;
			c2name = SpringLayout.EAST;
			c2spring = pad;
		}

		pad = Spring.constant(-xPad);
		c2 = parent;
		c2name = SpringLayout.EAST;
		c2spring = Spring.constant(-insetX);
		for (int col = columns - 1; col >= Math.max(0, springCol); col--) {
			Component c = null;
			for (int i = col; i < components.length; i += columns) {
				c = components[i];
				layout.putConstraint(SpringLayout.EAST, c, c2spring, c2name, c2);
			}
			c2 = c;
			c2name = SpringLayout.WEST;
			c2spring = pad;
		}
		
		// HEIGHT
		pad = Spring.constant(yPad);
		c2 = parent;
		c2name = SpringLayout.NORTH;
		c2spring = Spring.constant(insetY);
		Spring totalSizeY = c2spring;
		
		sizes = new ArrayList<Spring>();
		for (int row = 0; row <= maxRow; row++) {
			int startI = row * columns;
			int endI = Math.min(startI + columns, components.length) - 1;
			Spring height = Spring.constant(0);
			for (int i = startI; i <= endI; i++) {
				Component c = components[i];
				SpringLayout.Constraints cons = layout.getConstraints(c);
				height = Spring.max(height, cons.getHeight());
			}
			sizes.add(height);
			totalSizeY = Spring.sum(totalSizeY, c2spring);
			totalSizeY = Spring.sum(totalSizeY, height);
			c2spring = pad;
		}
		
		c2spring = Spring.constant(insetY);
		for (int row = 0; row <= maxRow; row++) {
			int startI = row * columns;
			int endI = Math.min(startI + columns, components.length) - 1;
			Spring height = sizes.get(row);

			Component c = null;
			for (int i = startI; i <= endI; i++) {
				c = components[i];
				SpringLayout.Constraints cons = layout.getConstraints(c);
				if (row != springRow) {
					cons.setHeight(height);
				}
				if (row <= springRow) {
					layout.putConstraint(SpringLayout.NORTH, c, c2spring, c2name, c2);
				}
			}
			c2 = c;
			c2name = SpringLayout.SOUTH;
			c2spring = pad;
		}

		pad = Spring.constant(-yPad);
		c2 = parent;
		c2name = SpringLayout.SOUTH;
		c2spring = Spring.constant(-insetY);
		for (int row = maxRow; row >= Math.max(0, springRow); row--) {
			int startI = row * columns;
			int endI = Math.min(startI + columns, components.length) - 1;
			Component c = null;
			for (int i = startI; i <= endI; i++) {
				c = components[i];
				layout.putConstraint(SpringLayout.SOUTH, c, c2spring, c2name, c2);
			}
			c2 = c;
			c2name = SpringLayout.NORTH;
			c2spring = pad;
		}

		parent.setPreferredSize(new Dimension(totalSizeX.getValue(), totalSizeY.getValue()));
	}

	public static <C extends JComponent> C addBorder(C c) {
		c.setBorder(BorderFactory.createLineBorder(Color.black));
		return c;
	}
	
	public static <C extends Container> C setEnabled(C container, boolean isEnabled) {
		if (container != null) {
			container.setEnabled(isEnabled);
			for (Component i : container.getComponents()) {
				if (i instanceof Container) {
					setEnabled((Container) i, isEnabled);
				}
			}
		}
		return container;
	}

	
	public static <C extends Component> C center(C c) {
		Dimension dim = Toolkit.getDefaultToolkit().getScreenSize();
		Dimension size = c.getSize();
		int x = Math.max(0, (dim.width - size.width) / 2);
		int y = Math.max(0, (dim.height - size.height) / 2);
		c.setLocation(x, y);
		return c;
	}
}
