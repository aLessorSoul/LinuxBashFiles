FROM 192.168.101.1:5000/spark-py:v3.1.1
# -----------------
# update with notebook
USER root
WORKDIR /root
# Install python3 infrastructure
COPY requirements.txt .
RUN mkdir ~/.pip
COPY pip.conf ~/.pip
RUN pip3 --no-cache-dir install -r requirements.txt && rm -f requirements.txt

RUN apt-get clean && apt-get autoremove -y && rm -rf /var/lib/apt/lists/*

COPY pyspark-3.1.1.tar.gz .
RUN pip3 install pyspark-3.1.1.tar.gz

# Clean up
RUN rm -rf /root/* && chmod 755 /root

RUN jupyter notebook --generate-config
RUN sed -i -E 's,^#\s*c.NotebookApp.terminado_settings.*,c.NotebookApp.terminado_settings = {"shell_command" : ["\/bin\/bash"]},g' ~/.jupyter/jupyter_notebook_config.py

# Setup password authentication so we don't have to remember tokens (password: "jupyter")
RUN echo "{ \"NotebookApp\": { \"password\": \"sha1:ad16e87de314:a02efac10ccd7ead24e845f438b2b87fe8bc2d0f\" } }" >> ~/.jupyter/jupyter_notebook_config.json
RUN mkdir -p ~/.ipython/profile_default
RUN echo "c.TerminalInteractiveShell.editing_mode = 'vi'" >> ~/.ipython/profile_default/ipython_config.py

# Required spark configuration for local user access
#ENV SPARK_HOME=/usr/local/spark
#ENV PYSPARK_PYTHON=python3
ENV PYSPARK_DRIVER_PYTHON=python3
ENV PYTHONPATH=${SPARK_HOME}/python:${SPARK_HOME}/python/lib/py4j-0.10.7-src.zip
ENV LD_LIBRARY_PATH=$LD_LIBRARY_PATH:/usr/local/lib
ENV PATH=/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin:${SPARK_HOME}/bin

EXPOSE 4040 4041 8080 8888 

ENTRYPOINT ["/usr/local/bin/jupyter"]

CMD ["notebook", "--no-browser", "--allow-root", "--ip=0.0.0.0", "--port=8888"]