const UserModel = require('./userModel');


class UserService{
    static async registerUser(email,password,housenumber,address){
        try{
            const createuser = new UserModel({email,password,housenumber,address});
            return await createuser.save();
        }catch(error){
            throw error;
        }
    

}};

module.exports = UserService;