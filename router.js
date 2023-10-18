const router  =require('express').Router();
const usercontroller = require('./usercontroller');


router.post('/registration',usercontroller.register);

module.exports = router;