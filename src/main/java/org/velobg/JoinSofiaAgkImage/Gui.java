package org.velobg.JoinSofiaAgkImage;

import java.awt.BorderLayout;
import java.awt.Color;
import java.awt.Dimension;
import java.awt.event.ActionEvent;
import java.awt.event.ActionListener;
import java.io.File;
import java.io.IOException;

import javax.swing.BorderFactory;
import javax.swing.ImageIcon;
import javax.swing.JButton;
import javax.swing.JComponent;
import javax.swing.JEditorPane;
import javax.swing.JFileChooser;
import javax.swing.JFrame;
import javax.swing.JLabel;
import javax.swing.JPanel;
import javax.swing.JProgressBar;
import javax.swing.JScrollPane;
import javax.swing.JTextArea;
import javax.swing.JTextField;
import javax.swing.SpringLayout;
import javax.swing.SwingUtilities;

public class Gui {
	static final int GAP = 10;
	JTextArea uiLog;
	JTextField uiUrl;
	JTextField uiFolder;
	JProgressBar uiProgressBar;
	
	JComponent createLeftPanel() throws IOException {
		JPanel panel = new JPanel();
		panel.setLayout(new SpringLayout());
		ImageIcon icon = new ImageIcon(Utils.loadStream(getClass().getResourceAsStream("velobg_org_logo.png")));
		panel.add(new JLabel(icon), BorderLayout.NORTH);
		StringPrintStream s = new StringPrintStream();
		Utils.copyStream(getClass().getResourceAsStream("helpinfo.htm"), s);
		JEditorPane l = new JEditorPane("text/html", s.toString());
		l.setBorder(BorderFactory.createLineBorder(Color.black));
		panel.add(l, BorderLayout.CENTER);
		Utils.makeSpringGrid(panel, 1, 1, 0, GAP, GAP / 2, GAP / 2, GAP/ 2);
		panel.setPreferredSize(new Dimension(350 + GAP + GAP, 0));
		
		return panel;
	}

	private void asynchRun() {
		JoinSofiaOupImage job = new JoinSofiaOupImage() {
			public void log(String str) {
				uiLog(str);
			}
			public void finishedDownloadingImage(int image, int numImages) {
				try {
					final int percentComplete = image * 100 / numImages;
					SwingUtilities.invokeAndWait(new Runnable() {
						public void run() {
							uiProgressBar.setValue(percentComplete);
						}
					});
				} catch (Exception e) {
					StringPrintStream s = new StringPrintStream();
					e.printStackTrace(s);
					uiLog(s.toString());
				}
			}
		};
		job.outputFolder = new File(uiFolder.getText());
		try {
			job.downloadAll(uiUrl.getText());
		} catch (Exception e) {
			StringPrintStream s = new StringPrintStream();
			e.printStackTrace(s);
			uiLog(s.toString());
		}
	}
	
	JComponent createFormFields() {
		final JPanel panel = new JPanel();
		panel.setLayout(new SpringLayout());

		JLabel l = new JLabel("URL");
		panel.add(l);
		uiUrl = new JTextField();
		l.setLabelFor(uiUrl);
		l.setDisplayedMnemonic('U');
		panel.add(uiUrl);
		panel.add(new JLabel());
		l = new JLabel("Folder");
		l.setDisplayedMnemonic('F');
		panel.add(l);
		uiFolder = new JTextField();
		l.setLabelFor(uiFolder);
		uiFolder.setText(new File(".").getAbsoluteFile().getParent());
		
		panel.add(uiFolder);
		JButton btnFolder = new JButton("Browse");
		btnFolder.addActionListener(new ActionListener() {
			public void actionPerformed(ActionEvent e) {
				JFileChooser j = new JFileChooser();
				j.setFileSelectionMode(JFileChooser.DIRECTORIES_ONLY);
				j.setDialogTitle("Избор на изходна директория");
				Integer opt = j.showDialog(uiUrl, "Избери");
				if (opt == JFileChooser.APPROVE_OPTION) {
					File fileToSave = j.getSelectedFile();
					uiFolder.setText(fileToSave.getAbsolutePath());
				}
			}
		});
		panel.add(btnFolder);

		panel.add(new JLabel());
		JButton btn = new JButton("Свали чертежите");
		btn.addActionListener(new ActionListener() {
			public void actionPerformed(ActionEvent e) {
				uiLog.setText("");
				new Thread(new Runnable() {
					public void run() {
						Utils.setEnabled(panel, false);
						asynchRun();
						Utils.setEnabled(panel, true);
					}
				}).start();
			}
		});
		panel.add(btn);

		Utils.makeSpringGrid(panel, 3, Integer.MAX_VALUE, 1, 0, 0, GAP, GAP / 2);
		return panel;
	}
	
	void uiLog(final String str) {
		try {
			SwingUtilities.invokeAndWait(new Runnable() {
				public void run() {
					uiLog.append(str);
					uiLog.append("\n");
				}
			});
		} catch (Exception e) {
			e.printStackTrace();
		}
	}
	
	JComponent createProgressBarAndLog() {
		JPanel panel = new JPanel();
		panel.setLayout(new SpringLayout());

		uiLog = new JTextArea();
		uiLog.setEditable(false);
		JScrollPane scroll = new JScrollPane (uiLog, JScrollPane.VERTICAL_SCROLLBAR_AS_NEEDED, JScrollPane.HORIZONTAL_SCROLLBAR_AS_NEEDED);
		panel.add(scroll);
		uiProgressBar = new JProgressBar(0, 100);
		panel.add(uiProgressBar);
		Utils.makeSpringGrid(panel, 1, 0, 0, 0, 0, GAP, GAP / 2);
		return panel;
	}
	
	JComponent createTopPanel() {
		JPanel panel = Utils.addBorder(new JPanel());
		panel.setLayout(new SpringLayout());
		
		panel.add(createFormFields());
		panel.add(createProgressBarAndLog());
		Utils.makeSpringGrid(panel, 1, 1, 0, GAP, GAP, GAP, GAP / 2);

		return panel;
	}
	
	void createAndShowGUI() throws Exception {
		JFrame frame = new JFrame(
				"Сваляне на чертежи от сайта на sofia-agk.com");
		frame.setDefaultCloseOperation(JFrame.EXIT_ON_CLOSE);
		JPanel panel = new JPanel();
		panel.setLayout(new BorderLayout());
		panel.add(createLeftPanel(), BorderLayout.WEST);
		panel.add(createTopPanel(), BorderLayout.CENTER);

		frame.add(panel);
		frame.setPreferredSize(new Dimension(800, 550));
		frame.pack();
		Utils.center(frame);
		frame.setVisible(true);

		uiUrl.requestFocus();
	}

	public static void main(String[] args) throws Exception {
		new Gui().createAndShowGUI();
	}
}
