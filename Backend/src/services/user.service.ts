import bcryptjs from "bcryptjs";
import jwt from "jsonwebtoken";
import { UserRepository } from "../repositories/user.repository";
import { CreateUserDto, LoginUserDTO, UpdateUserDTO } from "../dtos/user.dtos";
import { HttpError } from "../errors/https-error";
import { JWT_SECRET } from "../config";
import { deleteUploadIfExists } from "../middlewares/upload.middleware";


let userRepository = new UserRepository();

export class UserService {
  async createUser(data: CreateUserDto) {
    const emailCheck = await userRepository.getUserByEmail(data.email);
    if (emailCheck) {
      throw new HttpError(403, "Email already in use");
    }
    const hashedPassword = await bcryptjs.hash(data.password, 10);
    data.password = hashedPassword;

    const newUser = await userRepository.createUser(data);
    return newUser;
  }
  async loginUser(data: LoginUserDTO) {
    const user = await userRepository.getUserByEmail(data.email);
    if (!user) {
      throw new HttpError(404, "User not found");
    }
    if (!user.password) {
      throw new HttpError(
        401,
        "This account uses social login. Please continue with Google.",
      );
    }
    const validPassword = await bcryptjs.compare(data.password, user.password);
    if (!validPassword) {
      throw new HttpError(401, "Invalid credential");
    }

    const payload = {
      id: user._id,
      email: user.email,
      name: user.name,
      role: user.role,
    };
    const token = jwt.sign(payload, JWT_SECRET, { expiresIn: "30d" });
    return { token, user };
  }

  async getUserById(id: string) {
    const user = await userRepository.getUsersById(id);
    if (!user) {
      throw new HttpError(404, "User not found");
    }
    return user;
  }
  async updateUser(id: string, data: UpdateUserDTO) {
  const user = await userRepository.getUsersById(id);

  if (!user) {
    throw new HttpError(404, "User not found");
  }

  if (user.email !== data.email) {
    const emailCheck = await userRepository.getUserByEmail(data.email!);

    if (emailCheck) {
      throw new HttpError(403, "Email already in use");
    }
  }

  if (
    data.imageUrl &&
    user.imageUrl &&
    user.imageUrl !== data.imageUrl
  ) {
    try {
      deleteUploadIfExists(user.imageUrl);
    } catch (error) {
      console.error("Error deleting old image:", error);
    }
  }

  const updateUser = await userRepository.updateUser(id, data);

  return updateUser;
}
}