# Your version: 0.6.0+5.g74cb187.dirty Latest version: 0.7.0
# Generated by Neurodocker version 0.6.0+5.g74cb187.dirty
# Timestamp: 2020-08-19 20:25:29 UTC
# 
# Thank you for using Neurodocker. If you discover any issues
# or ways to improve this software, please submit an issue or
# pull request on our GitHub repository:
# 
#     https://github.com/kaczmarj/neurodocker

FROM neurodebian

USER root

ARG DEBIAN_FRONTEND="noninteractive"

ENV LANG="en_US.UTF-8" \
    LC_ALL="en_US.UTF-8" \
    ND_ENTRYPOINT="/neurodocker/startup.sh"
RUN export ND_ENTRYPOINT="/neurodocker/startup.sh" \
    && apt-get update -qq \
    && apt-get install -y -q --no-install-recommends \
           apt-utils \
           bzip2 \
           ca-certificates \
           curl \
           locales \
           unzip \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/* \
    && sed -i -e 's/# en_US.UTF-8 UTF-8/en_US.UTF-8 UTF-8/' /etc/locale.gen \
    && dpkg-reconfigure --frontend=noninteractive locales \
    && update-locale LANG="en_US.UTF-8" \
    && chmod 777 /opt && chmod a+s /opt \
    && mkdir -p /neurodocker \
    && if [ ! -f "$ND_ENTRYPOINT" ]; then \
         echo '#!/usr/bin/env bash' >> "$ND_ENTRYPOINT" \
    &&   echo 'set -e' >> "$ND_ENTRYPOINT" \
    &&   echo 'export USER="${USER:=`whoami`}"' >> "$ND_ENTRYPOINT" \
    &&   echo 'if [ -n "$1" ]; then "$@"; else /usr/bin/env bash; fi' >> "$ND_ENTRYPOINT"; \
    fi \
    && chmod -R 777 /neurodocker && chmod a+s /neurodocker

ENTRYPOINT ["/neurodocker/startup.sh"]

LABEL maintainer="Christopher J. Markiewicz"

ENV MKL_NUM_THREADS="1" \
    OMP_NUM_THREADS="1"

RUN test "$(getent passwd neuro)" || useradd --no-user-group --create-home --shell /bin/bash neuro
USER neuro

WORKDIR /home/neuro

ENV CONDA_DIR="/opt/miniconda-latest" \
    PATH="/opt/miniconda-latest/bin:$PATH"
RUN export PATH="/opt/miniconda-latest/bin:$PATH" \
    && echo "Downloading Miniconda installer ..." \
    && conda_installer="/tmp/miniconda.sh" \
    && curl -fsSL --retry 5 -o "$conda_installer" https://repo.continuum.io/miniconda/Miniconda3-latest-Linux-x86_64.sh \
    && bash "$conda_installer" -b -p /opt/miniconda-latest \
    && rm -f "$conda_installer" \
    && conda update -yq -nbase conda \
    && conda config --system --prepend channels conda-forge \
    && conda config --system --set auto_update_conda false \
    && conda config --system --set show_channel_urls true \
    && sync && conda clean --all && sync \
    && conda create -y -q --name neuro \
    && conda install -y -q --name neuro \
           "python=3.6" \
           "icu=64.2" \
           "mkl=2019.4" \
           "mkl-service=2.3.0" \
           "git=2.23.0" \
    && sync && conda clean --all && sync

RUN conda install -y -q --name neuro -c leej3 \
           "afni-minimal" \
           "numpy=1.17.2" \
           "scipy=1.3.1" \
           "scikit-learn=0.21.3" \
           "matplotlib=3.1.3" \
           "seaborn=0.10.0" \
           "pytables=3.5.2" \
           "pandas=0.25.1" \
           "patsy=0.5.1" \
           "traits=5.1.2" \
    && sync && conda clean --all && sync


COPY [".", "/src/fitlins"]

USER root

RUN mkdir /work && chown -R neuro /src /work && chmod a+w /work

USER neuro

ARG VERSION

RUN echo "$VERSION" > /src/fitlins/VERSION && sed -i -e 's/crashfile_format = pklz/crashfile_format = txt/' /src/fitlins/fitlins/data/nipype.cfg

RUN bash -c "source activate neuro \
    &&   pip install --no-cache-dir -r \
             "/src/fitlins/requirements.txt"" \
    && rm -rf ~/.cache/pip/* \
    && sync \
    && sed -i '$isource activate neuro' $ND_ENTRYPOINT

RUN bash -c "source activate neuro \
    &&   pip install --no-cache-dir  \
             "/src/fitlins[all]"" \
    && rm -rf ~/.cache/pip/* \
    && sync \
    && sed -i '$isource activate neuro' $ND_ENTRYPOINT

WORKDIR /work

ENTRYPOINT ["/neurodocker/startup.sh", "fitlins"]

ARG BUILD_DATE
ARG VCS_REF

LABEL org.label-schema.build-date="$BUILD_DATE" \
      org.label-schema.name="FitLins" \
      org.label-schema.description="FitLins - Fit Linear Models to BIDS datasets" \
      org.label-schema.url="http://github.com/poldracklab/fitlins" \
      org.label-schema.vcs-ref="$VCS_REF" \
      org.label-schema.vcs-url="https://github.com/poldracklab/fitlins" \
      org.label-schema.version="$VERSION" \
      org.label-schema.schema-version="1.0"

RUN echo '{ \
    \n  "pkg_manager": "apt", \
    \n  "instructions": [ \
    \n    [ \
    \n      "base", \
    \n      "neurodebian@sha256:5fbbad8c68525b588a459092254094436aae9dc1f3920f8d871a03053b10377c" \
    \n    ], \
    \n    [ \
    \n      "label", \
    \n      { \
    \n        "maintainer": "Christopher J. Markiewicz" \
    \n      } \
    \n    ], \
    \n    [ \
    \n      "env", \
    \n      { \
    \n        "MKL_NUM_THREADS": "1", \
    \n        "OMP_NUM_THREADS": "1" \
    \n      } \
    \n    ], \
    \n    [ \
    \n      "user", \
    \n      "neuro" \
    \n    ], \
    \n    [ \
    \n      "workdir", \
    \n      "/home/neuro" \
    \n    ], \
    \n    [ \
    \n      "miniconda", \
    \n      { \
    \n        "create_env": "neuro", \
    \n        "conda_install": [ \
    \n          "python=3.6", \
    \n          "icu=64.2", \
    \n          "mkl=2019.4", \
    \n          "mkl-service=2.3.0", \
    \n          "git=2.23.0" \
    \n        ] \
    \n      } \
    \n    ], \
    \n    [ \
    \n      "miniconda", \
    \n      { \
    \n        "use_env": "neuro", \
    \n        "conda_install": [ \
    \n          "numpy=1.17.2", \
    \n          "scipy=1.3.1", \
    \n          "scikit-learn=0.21.3", \
    \n          "matplotlib=3.1.3", \
    \n          "seaborn=0.10.0", \
    \n          "pytables=3.5.2", \
    \n          "pandas=0.25.1", \
    \n          "patsy=0.5.1", \
    \n          "traits=5.1.2" \
    \n        ] \
    \n      } \
    \n    ], \
    \n    [ \
    \n      "copy", \
    \n      [ \
    \n        ".", \
    \n        "/src/fitlins" \
    \n      ] \
    \n    ], \
    \n    [ \
    \n      "user", \
    \n      "root" \
    \n    ], \
    \n    [ \
    \n      "run", \
    \n      "mkdir /work && chown -R neuro /src /work && chmod a+w /work" \
    \n    ], \
    \n    [ \
    \n      "user", \
    \n      "neuro" \
    \n    ], \
    \n    [ \
    \n      "arg", \
    \n      { \
    \n        "VERSION": "" \
    \n      } \
    \n    ], \
    \n    [ \
    \n      "run", \
    \n      "echo \"$VERSION\" > /src/fitlins/VERSION && sed -i -e '"'"'s/crashfile_format = pklz/crashfile_format = txt/'"'"' /src/fitlins/fitlins/data/nipype.cfg" \
    \n    ], \
    \n    [ \
    \n      "miniconda", \
    \n      { \
    \n        "use_env": "neuro", \
    \n        "pip_opts": "-r", \
    \n        "pip_install": [ \
    \n          "/src/fitlins/requirements.txt" \
    \n        ], \
    \n        "activate": true \
    \n      } \
    \n    ], \
    \n    [ \
    \n      "miniconda", \
    \n      { \
    \n        "use_env": "neuro", \
    \n        "pip_install": [ \
    \n          "/src/fitlins[all]" \
    \n        ], \
    \n        "activate": true \
    \n      } \
    \n    ], \
    \n    [ \
    \n      "workdir", \
    \n      "/work" \
    \n    ], \
    \n    [ \
    \n      "entrypoint", \
    \n      "/neurodocker/startup.sh fitlins" \
    \n    ], \
    \n    [ \
    \n      "arg", \
    \n      { \
    \n        "BUILD_DATE": "", \
    \n        "VCS_REF": "" \
    \n      } \
    \n    ], \
    \n    [ \
    \n      "label", \
    \n      { \
    \n        "org.label-schema.build-date": "$BUILD_DATE", \
    \n        "org.label-schema.name": "FitLins", \
    \n        "org.label-schema.description": "FitLins - Fit Linear Models to BIDS datasets", \
    \n        "org.label-schema.url": "http://github.com/poldracklab/fitlins", \
    \n        "org.label-schema.vcs-ref": "$VCS_REF", \
    \n        "org.label-schema.vcs-url": "https://github.com/poldracklab/fitlins", \
    \n        "org.label-schema.version": "$VERSION", \
    \n        "org.label-schema.schema-version": "1.0" \
    \n      } \
    \n    ] \
    \n  ] \
    \n}' > /neurodocker/neurodocker_specs.json
