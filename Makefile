OUTDIR = out

configure:
	mkdir $(OUTDIR) && cd $(OUTDIR) && meson --prefix /usr ..

build:
	cd $(OUTDIR) && ninja -j$(shell nproc);

install:
	cd $(OUTDIR) && sudo ninja install
	bash check.sh

uninstall:
	cd $(OUTDIR) && sudo ninja uninstall

clean:
	rm -rf $(OUTDIR)

