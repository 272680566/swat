package com.swat.service;

import com.swat.mapper.UserMapper;
import com.swat.model.User;
import org.springframework.security.crypto.bcrypt.BCryptPasswordEncoder;
import org.springframework.stereotype.Service;

import java.util.HashMap;
import java.util.Map;
import java.util.UUID;

@Service
public class UserService {

    private final UserMapper userMapper;
    private final BCryptPasswordEncoder passwordEncoder = new BCryptPasswordEncoder();

    public UserService(UserMapper userMapper) {
        this.userMapper = userMapper;
    }

    public Map<String, Object> login(String username, String password) {
        Map<String, Object> result = new HashMap<>();

        User user = userMapper.findByUsername(username);
        if (user == null) {
            result.put("success", false);
            result.put("message", "用户名或密码错误");
            return result;
        }

        if (!passwordEncoder.matches(password, user.getPassword())) {
            result.put("success", false);
            result.put("message", "用户名或密码错误");
            return result;
        }

        String token = UUID.randomUUID().toString().replace("-", "");
        // In production, store token in Redis or DB. For simplicity, return it directly.
        result.put("success", true);
        result.put("message", "登录成功");
        result.put("token", token);
        result.put("username", user.getUsername());
        return result;
    }

    public Map<String, Object> register(String username, String password, String email) {
        Map<String, Object> result = new HashMap<>();

        User existing = userMapper.findByUsername(username);
        if (existing != null) {
            result.put("success", false);
            result.put("message", "用户名已存在");
            return result;
        }

        User user = new User();
        user.setUsername(username);
        user.setPassword(passwordEncoder.encode(password));
        user.setEmail(email);

        userMapper.insert(user);

        result.put("success", true);
        result.put("message", "注册成功");
        return result;
    }
}
