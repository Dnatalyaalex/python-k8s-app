FROM python:3
WORKDIR /usr/src/app
COPY ./requirements.txt ./
EXPOSE 5001
COPY . .
RUN groupadd -r appgroup && \
    useradd -r -g appgroup -s /sbin/nologin appuser
RUN pip install --no-cache-dir -r requirements.txt
RUN chown -R appuser:appgroup /usr/src/app
USER appuser
CMD [ "python", "./app.py" ]