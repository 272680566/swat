package com.swat.service;

import com.swat.mapper.RlMapper;
import com.swat.model.Rl;
import org.springframework.stereotype.Service;
import java.util.*;

@Service
public class RlService {
    private final RlMapper mapper;
    public RlService(RlMapper mapper) { this.mapper = mapper; }
    public List<Rl> list() { return mapper.findAll(); }
    public Map<String, Object> create(Rl rl) {
        Map<String, Object> result = new HashMap<>();
        if (rl.getName() == null || rl.getName().trim().isEmpty()) {
            result.put("success", false); result.put("message", "RL名称不能为空"); return result;
        }
        mapper.insert(rl);
        result.put("success", true); result.put("message", "创建成功"); result.put("data", rl);
        return result;
    }
    public Map<String, Object> update(Long id, Rl rl) {
        Map<String, Object> result = new HashMap<>();
        if (mapper.findById(id) == null) {
            result.put("success", false); result.put("message", "RL不存在"); return result;
        }
        rl.setId(id); mapper.update(rl);
        result.put("success", true); result.put("message", "更新成功");
        return result;
    }
    public Map<String, Object> delete(Long id) {
        Map<String, Object> result = new HashMap<>();
        if (mapper.findById(id) == null) {
            result.put("success", false); result.put("message", "RL不存在"); return result;
        }
        mapper.deleteById(id);
        result.put("success", true); result.put("message", "删除成功");
        return result;
    }
}
