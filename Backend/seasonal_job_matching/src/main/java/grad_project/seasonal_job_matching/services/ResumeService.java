package grad_project.seasonal_job_matching.services;

import java.util.ArrayList;
import java.util.Optional;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.cache.annotation.CacheEvict;
import org.springframework.cache.annotation.Cacheable;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import grad_project.seasonal_job_matching.model.Resume;
import grad_project.seasonal_job_matching.model.User;
import grad_project.seasonal_job_matching.repository.UserRepository;
import grad_project.seasonal_job_matching.repository.ResumeRepository;
import grad_project.seasonal_job_matching.mapper.ResumeMapper;
import grad_project.seasonal_job_matching.dto.responses.ResumeResponseDTO;
import grad_project.seasonal_job_matching.dto.requests.ResumeCreateDTO;
import grad_project.seasonal_job_matching.dto.requests.ResumeEditDTO;

@Service
public class ResumeService {

    // public final List<Resume> resumes = new ArrayList<>();
    private final UserRepository userRepository;
    private final ResumeRepository resumeRepository;

    @Autowired
    private ResumeMapper resumeMapper;

    public ResumeService(ResumeRepository resumeRepository, UserRepository userRepository) {
        this.userRepository = userRepository;
        this.resumeRepository = resumeRepository;
    }

    // could be deleted, i dont think we need to get all resumes at any point
    // public List<ResumeResponseDTO> findAllResumes(){
    // return resumeRepository.findAll()
    // .stream()
    // .map(resumeMapper::maptoreturnResume)
    // .collect(Collectors.toList());
    // }

    @Cacheable(value = "userResume", key = "#userId", unless = "#result.isEmpty()")
    @Transactional(readOnly = true)
    public Optional<ResumeResponseDTO> findResumeByUserId(long userId) {
        User user = userRepository.findByIdWithResume(userId)
                .orElseThrow(() -> new RuntimeException("User not found with ID: " + userId));
        Resume resume = user.getResume();

        if (resume == null) {
            throw new RuntimeException("User has no linked resume.");
        }

        // in job service, we dont write optional.of because findbyid returns optional
        // and so mapper returns optional jobresponsedto
        // while here, the optional chain is cut of so mapping doesnt return optional so
        // we have to typecast it
        // probably when adding sessions and cookies, this function will change, or
        // maybe the only thing will change will be in the
        // controller layer and instead of taking pathvariable, id will be taken from
        // session and function stays the same
        return Optional.of(resumeMapper.maptoreturnResume(resume));
    }

    // this function takes id from url OF user which isnt the best practice but
    // until i do session security to get user id from session and then take resume
    // from it
    @Transactional
    public ResumeResponseDTO createResume(ResumeCreateDTO dto, long userId) { // does it need any validation like unique
                                                                              // user email?
        // get user from id given in url
        User user = userRepository.findById(userId).orElseThrow(() -> new RuntimeException("User not found"));
        Resume resume = resumeMapper.maptoAddResume(dto);

        // Initialize lists if null (required for non-nullable database fields)
        if (resume.getEducation() == null) {
            resume.setEducation(new ArrayList<>());
        }
        if (resume.getExperience() == null) {
            resume.setExperience(new ArrayList<>());
        }
        if (resume.getCertificates() == null) {
            resume.setCertificates(new ArrayList<>());
        }
        if (resume.getSkills() == null) {
            resume.setSkills(new ArrayList<>());
        }
        if (resume.getLanguages() == null) {
            resume.setLanguages(new ArrayList<>());
        }

        Resume savedResume = resumeRepository.save(resume);
        user.setResume(savedResume);
        userRepository.save(user);// because we updated it
        return resumeMapper.maptoreturnResume(savedResume);

    }

    @CacheEvict(value = "userResume", key = "#userId")
    @Transactional
    public ResumeResponseDTO editResume(ResumeEditDTO dto, long userId) {
        User user = userRepository.findByIdWithResume(userId).orElseThrow(() -> new RuntimeException("User not found"));

        Resume existingResume = user.getResume();
        if (existingResume == null) {
            throw new RuntimeException("User has no linked resume. Please create a resume first.");
        }
        // This single line handles certificates, education, experience, and languages
        // if they were not arrays and wouldnt be ignored in mapper
        // If the DTO field is null (omitted in JSON), the existing value remains
        // unchanged.
        // resumeMapper.maptoEditResume(dto,existingResume);

        // Initialize skills list if null
        if (existingResume.getEducation() == null) {
            existingResume.setEducation(new ArrayList<>());
        }
        if (existingResume.getExperience() == null) {
            existingResume.setExperience(new ArrayList<>());
        }
        if (existingResume.getCertificates() == null) {
            existingResume.setCertificates(new ArrayList<>());
        }
        if (existingResume.getSkills() == null) {
            existingResume.setSkills(new ArrayList<>());
        }
        if (existingResume.getLanguages() == null) {
            existingResume.setLanguages(new ArrayList<>());
        }

        // Handle education
        if (dto.getEducationToAdd() != null) {
            for (String education : dto.getEducationToAdd()) {
                if (!existingResume.getEducation().contains(education)) {
                    existingResume.getEducation().add(education);
                }
            }
        }
        if (dto.getEducationToRemove() != null) {
            existingResume.getEducation().removeAll(dto.getEducationToRemove());
        }

        // Handle experience
        if (dto.getExperienceToAdd() != null) {
            for (String experience : dto.getExperienceToAdd()) {
                if (!existingResume.getExperience().contains(experience)) {
                    existingResume.getExperience().add(experience);
                }
            }
        }
        if (dto.getExperienceToRemove() != null) {
            existingResume.getExperience().removeAll(dto.getExperienceToRemove());
        }

        // Handle certificates
        if (dto.getCertificatesToAdd() != null) {
            for (String certificate : dto.getCertificatesToAdd()) {
                if (!existingResume.getCertificates().contains(certificate)) {
                    existingResume.getCertificates().add(certificate);
                }
            }
        }
        if (dto.getCertificatesToRemove() != null) {
            existingResume.getCertificates().removeAll(dto.getCertificatesToRemove());
        }

        // Handle languages
        if (dto.getLanguagesToAdd() != null) {
            for (String language : dto.getLanguagesToAdd()) {
                if (!existingResume.getLanguages().contains(language)) {
                    existingResume.getLanguages().add(language);
                }
            }
        }
        if (dto.getLanguagesToRemove() != null) {
            existingResume.getLanguages().removeAll(dto.getLanguagesToRemove());
        }

        // Handle skills
        if (dto.getSkillsToAdd() != null) {
            for (String skill : dto.getSkillsToAdd()) {
                if (!existingResume.getSkills().contains(skill)) {
                    existingResume.getSkills().add(skill);
                }
            }
        }

        // Remove skills
        if (dto.getSkillsToRemove() != null) {
            existingResume.getSkills().removeAll(dto.getSkillsToRemove());
        }

        Resume savedResume = resumeRepository.save(existingResume);
        return resumeMapper.maptoreturnResume(savedResume);

    }

    @CacheEvict(value = "userResume", key = "#userId")
    @Transactional
    public void deleteResume(Long userId) {
        User user = userRepository.findByIdWithResume(userId)
                .orElseThrow(() -> new RuntimeException("User not found with ID: " + userId));
        Resume resumeToDelete = user.getResume();
        if (resumeToDelete != null) {
            user.setResume(null);
            userRepository.save(user);
            resumeRepository.deleteById(resumeToDelete.getId());
        }
    }

}