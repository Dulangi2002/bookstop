

const mongoose = require('mongoose') ;
const app = require("./app");
const bcrypt = require('bcrypt');

const { Schema } = mongoose;
const userSchema = new Schema({
    email:{
        type: String,
        lowercase :true,
        unique:true,
        required:true

    },
    password:{
        type:String,
        required:true
    },

    housenumber:{
        type:String,
        required:true

    },

    address:{
        type:String,
        required:true
    },

});


userSchema.pre('save',async function(){
    try{
        var user = this;
        const salt = await bcrypt.genSalt(10);
        const hashedPassword = await bcrypt.hash(user.password,salt);
        user.password = hashedPassword;


    }catch(error){throw error;}
});



const UserModel = mongoose.model('User',userSchema);
module.exports = UserModel;


/* 
const User = mongoose.model('User', userSchema);
module.exports = User;*/