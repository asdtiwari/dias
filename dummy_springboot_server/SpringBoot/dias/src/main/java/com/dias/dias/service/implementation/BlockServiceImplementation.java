package com.dias.dias.service.implementation;

import org.springframework.stereotype.Service;

import com.dias.dias.service.BlockService;

@Service
public class BlockServiceImplementation implements BlockService {

    @Override
    public void blockUser(String username) {
        // Implement user blocking logic (e.g., update user status in the database)
    }

    @Override
    public void unblockUser(String username) {
        // Implement user unblocking logic
    }
}
