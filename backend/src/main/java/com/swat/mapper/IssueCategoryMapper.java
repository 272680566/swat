package com.swat.mapper;

import com.swat.model.IssueCategory;
import org.apache.ibatis.annotations.Mapper;
import org.apache.ibatis.annotations.Param;

import java.util.List;

@Mapper
public interface IssueCategoryMapper {

    List<IssueCategory> findAll();

    List<IssueCategory> findByLevel(@Param("level") Integer level);

    List<IssueCategory> findByParentId(@Param("parentId") Long parentId);

    IssueCategory findById(@Param("id") Long id);

    int insert(IssueCategory category);

    int update(IssueCategory category);

    int deleteById(@Param("id") Long id);

    int countByParentId(@Param("parentId") Long parentId);
}
