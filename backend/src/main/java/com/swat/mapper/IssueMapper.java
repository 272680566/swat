package com.swat.mapper;

import com.swat.model.Issue;
import org.apache.ibatis.annotations.Mapper;
import org.apache.ibatis.annotations.Param;

import java.util.List;

@Mapper
public interface IssueMapper {

    List<Issue> findAll(@Param("keyword") String keyword, @Param("status") String status,
                        @Param("filterDateStart") String filterDateStart,
                        @Param("filterDateEnd") String filterDateEnd,
                        @Param("filterCustomerName") String filterCustomerName,
                        @Param("filterKernelVersion") String filterKernelVersion,
                        @Param("filterUrgentRecover") String filterUrgentRecover,
                        @Param("offset") int offset, @Param("limit") int limit);

    int countFiltered(@Param("keyword") String keyword, @Param("status") String status,
                      @Param("filterDateStart") String filterDateStart,
                      @Param("filterDateEnd") String filterDateEnd,
                      @Param("filterCustomerName") String filterCustomerName,
                      @Param("filterKernelVersion") String filterKernelVersion,
                      @Param("filterUrgentRecover") String filterUrgentRecover);

    Issue findById(@Param("id") Long id);

    int countByDate(@Param("date") String date);

    int insert(Issue issue);

    int update(Issue issue);

    int deleteById(@Param("id") Long id);
}
