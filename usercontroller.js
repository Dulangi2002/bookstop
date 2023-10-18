const UserService = require('./userservice');


exports.register = async (req, res, next) => {
    try{
        const {email,password,housenumber, address} = req.body;
        const success = await UserService.registerUser(email,password,housenumber, address);
        res.json({status:true, success:"user registersed"});


    }catch(error){
        throw(error);
    }
};