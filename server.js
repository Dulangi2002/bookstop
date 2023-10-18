console.log("hello");
const app = require("./app");

const port = 5000;
const mongoose = require('mongoose');
const UserModel = require('./userModel'); 


app.get('/',(req,res)=>{
    res.send('hello world');
});
app.listen(port,()=>{
    console.log(`server is running on http://localhost:${port}`);
});




const connection = mongoose.connect('mongodb+srv://admin:Admin1234@bookstopapi.lukud4p.mongodb.net/BOOKSTOP1?retryWrites=true&w=majority',
{useNewUrlParser:true,useUnifiedTopology:true}

)


.then
(()=>{
    console.log('connected to database yayy');
}).catch((error)=>{console.log(error)});


module.exports = connection;
/*

app.post('/newuser', async (req , res)=>{
    
    console.log(req.body)
    const user  = await User.create(req.body)  
    
    res.status(200).json(user)
    
    

})

mongoose.connect('mongodb+srv://admin:admin1234@bookstopapi.lukud4p.mongodb.net/Bookstop?retryWrites=true&w=majority')
.then(()=>{
    console.log('connected t0 mongodb')
    app.listen(6000,()=>{
        console.log("node api app is running on port 6000")
    });
    
  

}).catch((error)=>{
    console.log(error)
})*/