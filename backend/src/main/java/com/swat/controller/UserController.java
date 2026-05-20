package com.swat.controller;

import com.swat.service.UserService;
import org.springframework.web.bind.annotation.*;

import java.util.Map;

@RestController
@RequestMapping("/api/user")
public class UserController {

    private final UserService userService;

    public UserController(UserService userService) {
        this.userService = userService;
    }

    @PostMapping("/login")
    public Map<String, Object> login(@RequestBody Map<String, String> body) {
        String username = body.get("username");
        String password = body.get("password");

        if (username == null || username.trim().isEmpty()
                || password == null || password.trim().isEmpty()) {
            Map<String, Object> result = new java.util.HashMap<>();
            result.put("success", false);
            result.put("message", "用户名和密码不能为空");
            return result;
        }

        return userService.login(username.trim(), password);
    }

    @PostMapping("/register")
    public Map<String, Object> register(@RequestBody Map<String, String> body) {
        String username = body.get("username");
        String password = body.get("password");
        String email = body.getOrDefault("email", "");

        if (username == null || username.trim().isEmpty()
                || password == null || password.trim().isEmpty()) {
            Map<String, Object> result = new java.util.HashMap<>();
            result.put("success", false);
            result.put("message", "用户名和密码不能为空");
            return result;
        }

        return userService.register(username.trim(), password, email.trim());
    }
}
