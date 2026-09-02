package com.example.contacts.controller;

import com.example.contacts.model.Contact;
import com.example.contacts.repository.ContactRepository;
import jakarta.validation.Valid;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.net.URI;
import java.util.List;
import java.util.Map;

@RestController
@RequestMapping("/api/contacts")
public class ContactController {

    private final ContactRepository repository;

    public ContactController(ContactRepository repository) {
        this.repository = repository;
    }

    /** 列表 / 搜索 */
    @GetMapping
    public List<Contact> list(@RequestParam(required = false) String keyword) {
        if (keyword == null || keyword.isBlank()) {
            return repository.findAll();
        }
        return repository.search(keyword.trim());
    }

    /** 详情 */
    @GetMapping("/{id}")
    public ResponseEntity<Contact> detail(@PathVariable Long id) {
        return repository.findById(id)
                .map(ResponseEntity::ok)
                .orElse(ResponseEntity.notFound().build());
    }

    /** 新增 */
    @PostMapping
    public ResponseEntity<Contact> create(@Valid @RequestBody Contact contact) {
        contact.setId(null);
        Contact saved = repository.save(contact);
        return ResponseEntity.created(URI.create("/api/contacts/" + saved.getId())).body(saved);
    }

    /** 修改 */
    @PutMapping("/{id}")
    public ResponseEntity<?> update(@PathVariable Long id, @Valid @RequestBody Contact contact) {
        return repository.findById(id)
                .map(existing -> {
                    existing.setName(contact.getName());
                    existing.setPhone(contact.getPhone());
                    existing.setEmail(contact.getEmail());
                    existing.setAddress(contact.getAddress());
                    existing.setNotes(contact.getNotes());
                    return ResponseEntity.ok(repository.save(existing));
                })
                .orElse(ResponseEntity.notFound().build());
    }

    /** 删除 */
    @DeleteMapping("/{id}")
    public ResponseEntity<Void> delete(@PathVariable Long id) {
        if (!repository.existsById(id)) {
            return ResponseEntity.notFound().build();
        }
        repository.deleteById(id);
        return ResponseEntity.noContent().build();
    }

    /** 参数校验失败时返回统一错误信息 */
    @ExceptionHandler(org.springframework.web.bind.MethodArgumentNotValidException.class)
    public Map<String, String> handleValidation(org.springframework.web.bind.MethodArgumentNotValidException e) {
        String msg = e.getBindingResult().getFieldErrors().stream()
                .map(err -> err.getDefaultMessage())
                .findFirst()
                .orElse("参数不合法");
        return Map.of("message", msg);
    }
}
