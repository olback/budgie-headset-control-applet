OUTDIR = out

configure:
	mkdir $(OUTDIR) && cd $(OUTDIR) && meson --prefix /usr ..

build:
	cd $(OUTDIR) && ninja;

install:
	cd $(OUTDIR) && sudo ninja install

uninstall:
	cd $(OUTDIR) && sudo ninja uninstall

clean:
	rm -rf $(OUTDIR)

