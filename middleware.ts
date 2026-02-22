import { Request, Response, NextFunction } from 'express';

// Middleware to protect routes and handle authentication
export const authenticate = (req: Request, res: Response, next: NextFunction) => {
    const token = req.headers['authorization'];
    
    if (!token) {
        return res.status(401).json({ message: 'Unauthorized access. No token provided.' });
    }
    
    // Verify token logic here
    // If token is valid, call next()
    // If token is invalid, return an error response

    next(); // proceed to the next middleware or route handler
};


// Example usage:
// app.use('/protected-route', authenticate);
