import { Request, Response } from "express";
import z from "zod";
import { UserService } from "../services/user.service";
import { CreateUserDto, LoginUserDTO, UpdateUserDTO } from "../dtos/user.dtos";


let userService = new UserService();
interface QueryParams {
    page?: string;
    size?: string;
    search?: string;
}

export class AuthController{
    async register (req: Request, res: Response){
        try{
            const parsedData = CreateUserDto.safeParse(req.body);
            if(!parsedData.success){
                return res.status(400).json(
                    {success: false, message: z.prettifyError(parsedData.error)}
                )
            }
            const userData: CreateUserDto = parsedData.data;
            const newUser = await userService.createUser(userData);
            return res.status(201).json(
                {success:true, message:"Registration Successful", data: newUser}
            );
        }catch(error: Error | any){
            return res.status(error.statusCode ?? 500).json(
                {success:false, message: error.message || "Internal Server Error"}
            );

        }
    }
    async login(req: Request, res:Response){
        try{
            const parsedData = LoginUserDTO.safeParse(req.body);
            if(!parsedData.success){
                return res.status(400).json(
                    {success:false, message: z.prettifyError(parsedData.error)}
                )
            }
            const loginData: LoginUserDTO = parsedData.data;
            const{token, user} = await userService.loginUser(loginData);
            return res.status(200).json(
                {success: true, messaage:"Login successful", data:user, token}
            );
        }catch(error: Error | any){
            return res.status(error.statusCode ?? 500).json(
                {success:false, message: error.message || "Internal Server Error"}
            );

        }
    }

    async getUserById(req: Request, res: Response){
        try{
            const userId = req.user?._id;
            
            if(!userId){
                return res.status(400).json(
                    {success: false, message: "User Id not provided"}
                );
            }
            const user = await userService.getUserById(userId);
            return res.status(200).json(
                {success: true, message:"user fetched successfully", data: user}
            );
        }catch(error: Error | any){
            return res.status(error.statusCode??500).json(
                {success: false, message: error.message ||"internal Server error"}
            );
        }
    }

    async updateUser(req: Request, res: Response) {
        try{
            const userId = req.params.id || req.user?._id;
            if(!userId){
                return res.status(400).json(
                    { success: false, message: "User ID not provided" }
                );
            }
            let parsedData = UpdateUserDTO.safeParse(req.body);
            if (!parsedData.success) {
                return res.status(400).json(
                    { success: false, message: z.prettifyError(parsedData.error) }
                )
            }
            if(req.file){ // if file is being uploaded
                parsedData.data.imageUrl = `/uploads/${req.file.filename}`;
            }
            const updatedUser = await userService.updateUser(userId, parsedData.data);
            return res.status(200).json(
                { success: true, message: "User updated successfully", data: updatedUser }
            );
        }catch (error: Error | any) {
            return res.status(error.statusCode ?? 500).json(
                { success: false, message: error.message || "Internal Server Error" }
            );
        }
    }

     async getOneUser(req: Request, res: Response){
        try{
            const userId = req.params.id as string; // routes /:id
            const user = await userService.getOneUser(userId);
            return res.status(200).json(
                { success: true, data: user }
            );
        }catch(error: Error | any){
            return res.status(error.statusCode ?? 500).json(
                {success: false, message: error.message || "Internal Server Error" }
            );   
        }
    }

    
    async getAllUsers(req: Request, res: Response) {
        try {
            const queryParams = req.query as QueryParams;

            const { users, pagination } = await userService.getAllUsers(
                queryParams.page,
                queryParams.size,
                queryParams.search
            );

            return res.status(200).json({
                success: true,
                data: users,
                pagination
            });
        } catch (error: Error | any) {
            return res.status(500).json({
                success: false,
                message: "Internal server error"
            });
        }
    }

async deleteUser(req: Request, res: Response) {
  try {
    const userId = req.params.id || req.user?._id;

    if (!userId) {
      return res.status(400).json({
        success: false,
        message: "User ID is required",
      });
    }

    const isDeleted = await userService.deleteUser(userId);

    if (!isDeleted) {
      return res.status(404).json({
        success: false,
        message: "User not found",
      });
    }

    return res.status(200).json({
      success: true,
      message: "User deleted successfully",
    });

  } catch (error) {
    return res.status(500).json({
      success: false,
      message: "Internal server error",
    });
  }
}

}
