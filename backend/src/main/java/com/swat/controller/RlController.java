package com.swat.controller;

import com.swat.model.Rl;
import com.swat.service.RlService;
import org.springframework.web.bind.annotation.*;
import java.util.*;

@RestController
@RequestMapping("/api/rls")
public class RlController {
    private final RlService service;
    public RlController(RlService service) { this.service = service; }

    @GetMapping
    public Object list() { return service.list(); }

    @GetMapping("/{id}")
    public Object getById(@PathVariable Long id) {
        for (Rl r : service.list()) { if (r.getId().equals(id)) return r; }
        Map<String, Object> err = new HashMap<>();
        err.put("success", false); err.put("message", "RL不存在"); return err;
    }

    @PostMapping
    public Map<String, Object> create(@RequestBody Rl rl) { return service.create(rl); }

    @PutMapping("/{id}")
    public Map<String, Object> update(@PathVariable Long id, @RequestBody Rl rl) { return service.update(id, rl); }

    @DeleteMapping("/{id}")
    public Map<String, Object> delete(@PathVariable Long id) { return service.delete(id); }
}
