#!/bin/sh

mkdir $HOME/gtkperf_env

tar -zxvf gtkperf_0.40.tar.gz
cd gtkperf/

cp /usr/share/automake-`automake --version | head -n1 | awk -F' ' '{print $4}' | rev | cut -c3- | rev`/config.guess .

patch -p1 <<'EOT'
--- gtkperf/src/callbacks.c	2005-10-30 11:33:42.000000000 +0000
+++ gtkperf-patched/src/callbacks.c	2008-05-23 23:41:17.000000000 +0100
@@ -219,6 +219,13 @@
 }


+void
+on_cmdline_test(char *optarg)
+{
+	appdata->test_type = atoi(optarg);
+}
+
+
 /* Initialize appdata */
 void
 setup_appdata(AppData * appdata_in)
@@ -398,7 +405,7 @@
 	appdata->pixbuf_drawing = gdk_pixbuf_new_from_file (filename, NULL);

 	gtk_combo_box_set_active (GTK_COMBO_BOX (appdata->combobox_testtype),
-				  0);
+				  appdata->test_type);

 	/* create end mark to info textview */
 	GtkTextIter iter;
--- gtkperf/src/callbacks.h	2005-10-30 10:21:23.000000000 +0000
+++ gtkperf-patched/src/callbacks.h	2008-05-23 23:22:30.000000000 +0100
@@ -13,6 +13,8 @@
 void on_cmdline_run_all ();
 void on_cmdline_help () ;
 void on_cmdline_count (char *optarg) ;
+void on_cmdline_test (char *optarg) ;
+void setup_appdata(AppData * appdata_in);
 void on_window_main_show (AppData * data);

 gboolean
--- gtkperf/src/main.c	2005-10-30 11:26:42.000000000 +0000
+++ gtkperf-patched/src/main.c	2008-05-23 23:44:02.000000000 +0100
@@ -65,9 +65,10 @@
 			{"help", 0, 0, 0},
 			{"automatic", 0, 0, 0},
 			{"count", 1, 0, 0},
+			{"test", 1, 0, 0},
 			{0, 0, 0, 0}
 		};
-		c = getopt_long (argc, argv, "hac:",
+		c = getopt_long (argc, argv, "hac:t:",
 			long_options, &option_index);
 		if (c == -1)
 			break;
@@ -104,6 +105,10 @@
 				on_cmdline_count(optarg);
 				break;

+			case 't':
+				on_cmdline_test(optarg);
+				break;
+
 			default:
 			case 'h':
 				on_cmdline_help ();

EOT

./configure --prefix=$HOME/gtkperf_env
make -j $NUM_CPU_JOBS
echo $? > ~/install-exit-status
make install
cd ..
rm -rf gtkperf/

cat > gtkperf <<'EOT'
#!/bin/sh

case "$1" in
"COMBOBOX")
	test=2
	;;
"COMBOBOX_ENTRY")
	test=3
	;;
"TOGGLE_BUTTON")
	test=6
	;;
"CHECK_BUTTON")
	test=7
	;;
"RADIO_BUTTON")
	test=8
	;;
"TEXTVIEW_ADD")
	test=9
	;;
"TEXTVIEW_SCROLL")
	test=10
	;;
"DRAWING_CIRCLES")
	test=12
	;;
"DRAWING_PIXBUFS")
	test=14
	;;
"TOTAL_TIME")
	test=0
	;;
esac

./gtkperf_env/bin/gtkperf -a -c 5000 -t $test > $LOG_FILE

EOT

chmod +x gtkperf
