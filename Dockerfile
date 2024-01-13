FROM bref/php-83-fpm
 
# Copy the source code in the image
# COPY .. /var/task
# binutils is needed for "strip" command
RUN yum install \
  tar \
  gzip \
  libdbusmenu.x86_64 \
  libdbusmenu-gtk2.x86_64 \
  libSM.x86_64 \
  xorg-x11-fonts-* \
  google-noto-sans-cjk-fonts.noarch \
  binutils.x86_64 \
  -y && \
  yum clean all

RUN set -xo pipefail && \
  curl "https://ftp.halifax.rwth-aachen.de/tdf/libreoffice/stable/7.6.4/rpm/x86_64/LibreOffice_7.6.4_Linux_x86-64_rpm.tar.gz" | tar -xz

# Install LibreOffice
RUN cd LibreOffice_7.6.4.1_Linux_x86-64_rpm/RPMS && \
  yum install *.rpm -y && \
  rm -rf /var/task/LibreOffice_7.6.4.1* && \
  cd /opt/libreoffice7.6/ && \
  strip ./**/* || true

ENV HOME=/tmp
# Trigger dummy run to generate bootstrap files to improve cold start performance
RUN mkdir /var/task/tmp && touch /var/task/tmp/test.docx \
  && cd /var/task/tmp \
  && libreoffice7.6 --headless --invisible --nodefault --view \
  --nolockcheck --nologo --norestore --convert-to pdf \
  --outdir /var/task/tmp /var/task/tmp/test.docx \
  && rm /var/task/tmp/* && rmdir /var/task/tmp
