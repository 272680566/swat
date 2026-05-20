package com.swat.mapper;

import com.swat.model.Rl;
import org.apache.ibatis.annotations.Mapper;
import org.apache.ibatis.annotations.Param;
import java.util.List;

@Mapper
public interface RlMapper {
    List<Rl> findAll();
    Rl findById(@Param("id") Long id);
    int insert(Rl rl);
    int update(Rl rl);
    int deleteById(@Param("id") Long id);
}
