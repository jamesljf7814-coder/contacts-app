package com.example.contacts.repository;

import com.example.contacts.model.Contact;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;

import java.util.List;

public interface ContactRepository extends JpaRepository<Contact, Long> {

    @Query("""
            SELECT c FROM Contact c
            WHERE LOWER(c.name)  LIKE LOWER(CONCAT('%', :keyword, '%'))
               OR c.phone        LIKE CONCAT('%', :keyword, '%')
               OR LOWER(c.email) LIKE LOWER(CONCAT('%', :keyword, '%'))
            """)
    List<Contact> search(@Param("keyword") String keyword);
}
