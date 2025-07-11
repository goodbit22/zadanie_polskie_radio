import os
from minio import Minio
from minio.error import S3Error
from dotenv import load_dotenv

MINIO_ENDPOINT = os.getenv("MINIO_ENDPOINT")
MINIO_ACCESS_KEY = os.getenv("MINIO_ACCESS_KEY")
MINIO_SECRET_KEY = os.getenv("MINIO_SECRET_KEY")
MINIO_SECURE = os.getenv("MINIO_SECURE", "false").lower() == "true"
MINIO_SECURE = False                   # True if using HTTPS
BUCKET_NAME = "my-bucket"
LOCAL_FOLDER = "./images"  # the folder containing files to upload

def main():
    if not (MINIO_ENDPOINT and MINIO_ACCESS_KEY and MINIO_SECRET_KEY):
        print("Please set MINIO_ENDPOINT, MINIO_ACCESS_KEY, and MINIO_SECRET_KEY in your .env file.")
        return
    try:
        client = Minio(
            MINIO_ENDPOINT,
            access_key=MINIO_ACCESS_KEY,
            secret_key=MINIO_SECRET_KEY,
            secure=MINIO_SECURE
        )

        # Create bucket if it doesn't exist
        if not client.bucket_exists(BUCKET_NAME):
            client.make_bucket(BUCKET_NAME)
            print(f"Bucket '{BUCKET_NAME}' created.")
        else:
            print(f"Bucket '{BUCKET_NAME}' already exists.")

        # Upload all files in the folder
        for root, dirs, files in os.walk(LOCAL_FOLDER):
            for filename in files:
                local_file_path = os.path.join(root, filename)
                # Object name = relative path from LOCAL_FOLDER
                object_name = os.path.relpath(local_file_path, LOCAL_FOLDER)
                object_name = object_name.replace("\\", "/")  # For Windows paths

                client.fput_object(BUCKET_NAME, object_name, local_file_path)
                print(f"Uploaded: {local_file_path} -> {object_name}")

        print("All files uploaded successfully.")

    except S3Error as err:
        print(f"MinIO error: {err}")

if __name__ == "__main__":
    if  os.path.isfile(".env"):
        load_dotenv()
    else: 
        print("The file .env does not exist")
    main()
