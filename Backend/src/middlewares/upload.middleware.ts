import multer from "multer";
import { v4 as uuidv4 } from "uuid";
import path from "path";
import fs from "fs";
import { Request } from "express";
import { HttpError } from "../errors/https-error";

// Ensure the uploads directory exists
const uploadDir = path.join(__dirname, "../../uploads");

if (!fs.existsSync(uploadDir)) {
  fs.mkdirSync(uploadDir, { recursive: true });
}

// Delete uploaded file if it exists
export const deleteUploadIfExists = (filePath: string): void => {
  try {
    const filename = path.basename(filePath);
    const fullPath = path.join(uploadDir, filename);

    if (fs.existsSync(fullPath)) {
      fs.unlinkSync(fullPath);
    }
  } catch (error) {
    console.error("Error deleting file:", error);
  }
};

const storage = multer.diskStorage({
  destination: function (req, file, cb) {
    cb(null, uploadDir);
  },

  filename: function (req, file, cb) {
    const ext = path.extname(file.originalname);
    const filename = `${uuidv4()}${ext}`;
    cb(null, filename);
  },
});

const fileFilter = (
  req: Request,
  file: Express.Multer.File,
  cb: multer.FileFilterCallback
) => {
  const allowedMimeTypes = [
    "image/jpeg",
    "image/png",
    "image/gif",
  ];

  if (allowedMimeTypes.includes(file.mimetype)) {
    cb(null, true);
  } else {
    cb(
      new HttpError(
        400,
        "Invalid file type. Only JPEG, PNG and GIF are allowed."
      )
    );
  }
};

const upload = multer({
  storage: storage,
  fileFilter: fileFilter,
  limits: {
    fileSize: 5 * 1024 * 1024, // 5 MB
  },
});

export const uploads = {
  single: (fieldName: string) => upload.single(fieldName),

  array: (fieldName: string, maxCount: number) =>
    upload.array(fieldName, maxCount),

  fields: (fields: { name: string; maxCount?: number }[]) =>
    upload.fields(fields),
};