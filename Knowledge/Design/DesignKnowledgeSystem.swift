//
//  DesignKnowledgeSystem.swift
//  HIG
//
//  Comprehensive design knowledge system covering all design disciplines
//  From graphic design to UX research, motion design to information architecture
//

import Foundation
import Combine

@MainActor
class DesignKnowledgeSystem: ObservableObject {
    
    static let shared = DesignKnowledgeSystem()
    
    // MARK: - Published State
    
    @Published var designDisciplines: [DesignDiscipline] = []
    @Published var designResources: [DesignResource] = []
    @Published var designTools: [DesignTool] = []
    @Published var designPrinciples: [DesignPrinciple] = []
    @Published var careerPaths: [CareerPath] = []
    @Published var patterns: [UIDesignPattern] = []
    @Published var guidelines: [DesignGuideline] = []
    @Published var examples: [DesignExample] = []
    @Published var isLoading = false
    
    private init() {
        loadDesignKnowledge()
    }
    
    // MARK: - Load Knowledge Base
    
    private func loadDesignKnowledge() {
        designDisciplines = createDesignDisciplines()
        designResources = createDesignResources()
        designTools = createDesignTools()
        designPrinciples = createDesignPrinciples()
        careerPaths = createCareerPaths()
        patterns = createDesignPatterns()
        guidelines = createDesignGuidelines()
        examples = createDesignExamples()
    }
    
    private func createDesignPatterns() -> [UIDesignPattern] {
        [
            UIDesignPattern(
                name: "Card Layout",
                description: "Organize content in card-based layouts",
                category: "Layout",
                codeExample: "VStack { CardView() }",
                useCases: ["Content organization", "Visual hierarchy"]
            )
        ]
    }
    
    private func createDesignGuidelines() -> [DesignGuideline] {
        [
            DesignGuideline(
                title: "Typography Hierarchy",
                description: "Establish clear visual hierarchy with typography",
                category: "Typography",
                examples: ["Use larger fonts for headings"],
                dosList: ["Use consistent font sizes"],
                dontsList: ["Mix too many font families"]
            )
        ]
    }
    
    private func createDesignExamples() -> [DesignExample] {
        [
            DesignExample(
                title: "Button Example",
                description: "Standard button implementation",
                code: "Button(\"Click Me\") { }",
                category: "Components"
            )
        ]
    }
    
    // MARK: - Design Disciplines
    
    private func createDesignDisciplines() -> [DesignDiscipline] {
        [
            // Graphic Design
            DesignDiscipline(
                id: "graphic-design",
                name: "Graphic Design",
                icon: "paintbrush.pointed",
                color: "#FF6B6B",
                description: "Visual communication through typography, imagery, color, and form",
                overview: """
                Graphic design is the art and practice of planning and projecting ideas and experiences with visual and textual content. It involves creating visual concepts to communicate ideas that inspire, inform, and captivate consumers.
                
                ## Core Competencies
                - Typography and type systems
                - Color theory and application
                - Layout and composition
                - Brand identity design
                - Print and digital media
                - Visual hierarchy
                - Grid systems
                
                ## Key Skills
                - Adobe Creative Suite mastery
                - Understanding of design principles
                - Strong visual communication
                - Attention to detail
                - Creative problem-solving
                """,
                keySkills: [
                    "Typography", "Color Theory", "Layout Design", "Brand Identity",
                    "Print Design", "Digital Design", "Illustration", "Photo Editing"
                ],
                tools: [
                    "Adobe Photoshop", "Adobe Illustrator", "Adobe InDesign",
                    "Figma", "Sketch", "Affinity Designer"
                ],
                learningResources: [
                    LearningResource(
                        title: "The Elements of Typographic Style",
                        type: .book,
                        author: "Robert Bringhurst",
                        url: nil
                    ),
                    LearningResource(
                        title: "Thinking with Type",
                        type: .book,
                        author: "Ellen Lupton",
                        url: nil
                    )
                ],
                careerLevels: [
                    "Junior Graphic Designer",
                    "Graphic Designer",
                    "Senior Graphic Designer",
                    "Art Director",
                    "Creative Director"
                ],
                salaryRange: "$45K - $120K+",
                demandLevel: .high
            ),
            
            // Product Design
            DesignDiscipline(
                id: "product-design",
                name: "Product Design",
                icon: "cube.box",
                color: "#4ECDC4",
                description: "End-to-end design of digital products from concept to launch",
                overview: """
                Product design combines UX, UI, and business strategy to create cohesive digital products. Product designers own the entire design process and work closely with engineering and product management.
                
                ## Core Competencies
                - User research and testing
                - Wireframing and prototyping
                - Visual design and UI
                - Design systems
                - Product strategy
                - Cross-functional collaboration
                - Data-driven design decisions
                
                ## Key Responsibilities
                - Define product vision and strategy
                - Conduct user research
                - Create wireframes and prototypes
                - Design high-fidelity interfaces
                - Collaborate with engineers
                - Measure and iterate on designs
                """,
                keySkills: [
                    "UX Design", "UI Design", "Prototyping", "User Research",
                    "Design Systems", "Product Strategy", "Interaction Design", "Visual Design"
                ],
                tools: [
                    "Figma", "Sketch", "Adobe XD", "Framer",
                    "Principle", "ProtoPie", "Miro", "FigJam"
                ],
                learningResources: [
                    LearningResource(
                        title: "The Design of Everyday Things",
                        type: .book,
                        author: "Don Norman",
                        url: nil
                    ),
                    LearningResource(
                        title: "Hooked: How to Build Habit-Forming Products",
                        type: .book,
                        author: "Nir Eyal",
                        url: nil
                    )
                ],
                careerLevels: [
                    "Associate Product Designer",
                    "Product Designer",
                    "Senior Product Designer",
                    "Lead Product Designer",
                    "Principal Product Designer",
                    "VP of Design"
                ],
                salaryRange: "$70K - $200K+",
                demandLevel: .veryHigh
            ),
            
            // UI Designer
            DesignDiscipline(
                id: "ui-design",
                name: "User Interface (UI) Design",
                icon: "rectangle.on.rectangle",
                color: "#95E1D3",
                description: "Crafting beautiful, functional interfaces for digital products",
                overview: """
                UI design focuses on the visual and interactive elements of digital interfaces. UI designers create the look and feel of applications, ensuring they're both aesthetically pleasing and functional.
                
                ## Core Competencies
                - Visual design principles
                - Typography and iconography
                - Color systems
                - Component design
                - Design systems
                - Responsive design
                - Accessibility standards
                
                ## Design Process
                1. Understand requirements
                2. Create mood boards
                3. Design components
                4. Build design system
                5. Create high-fidelity mockups
                6. Handoff to developers
                """,
                keySkills: [
                    "Visual Design", "Typography", "Color Theory", "Iconography",
                    "Design Systems", "Responsive Design", "Accessibility", "Micro-interactions"
                ],
                tools: [
                    "Figma", "Sketch", "Adobe XD", "Framer",
                    "Zeplin", "InVision", "Abstract"
                ],
                learningResources: [
                    LearningResource(
                        title: "Refactoring UI",
                        type: .book,
                        author: "Adam Wathan & Steve Schoger",
                        url: "https://refactoringui.com"
                    )
                ],
                careerLevels: [
                    "Junior UI Designer",
                    "UI Designer",
                    "Senior UI Designer",
                    "Lead UI Designer"
                ],
                salaryRange: "$50K - $140K+",
                demandLevel: .high
            ),
            
            // Visual Designer
            DesignDiscipline(
                id: "visual-design",
                name: "Visual Designer",
                icon: "paintpalette",
                color: "#F38181",
                description: "Creating compelling visual experiences across all touchpoints",
                overview: """
                Visual designers focus on aesthetics and visual communication across all mediums. They bridge the gap between graphic design and UI design, creating cohesive visual languages for brands and products.
                
                ## Core Competencies
                - Brand visual identity
                - Marketing materials
                - Digital and print design
                - Motion graphics basics
                - Photography and image editing
                - Illustration
                - Visual storytelling
                """,
                keySkills: [
                    "Visual Communication", "Brand Design", "Illustration", "Photography",
                    "Motion Graphics", "Print Design", "Digital Design", "Art Direction"
                ],
                tools: [
                    "Adobe Creative Suite", "Figma", "Sketch",
                    "After Effects", "Cinema 4D", "Blender"
                ],
                learningResources: [],
                careerLevels: [
                    "Visual Designer",
                    "Senior Visual Designer",
                    "Art Director",
                    "Creative Director"
                ],
                salaryRange: "$55K - $130K+",
                demandLevel: .medium
            ),
            
            // UX Designer
            DesignDiscipline(
                id: "ux-design",
                name: "User Experience (UX) Designer",
                icon: "person.crop.circle.badge.checkmark",
                color: "#AA96DA",
                description: "Designing intuitive, user-centered experiences",
                overview: """
                UX designers focus on the overall feel and usability of a product. They conduct research, create user flows, wireframes, and prototypes to ensure products are intuitive and meet user needs.
                
                ## Core Competencies
                - User research methodologies
                - Information architecture
                - User flows and journey mapping
                - Wireframing and prototyping
                - Usability testing
                - Interaction design
                - Accessibility
                
                ## UX Process
                1. Research (user interviews, surveys)
                2. Define (personas, user stories)
                3. Ideate (sketching, brainstorming)
                4. Prototype (wireframes, prototypes)
                5. Test (usability testing)
                6. Iterate (refine based on feedback)
                """,
                keySkills: [
                    "User Research", "Wireframing", "Prototyping", "Usability Testing",
                    "Information Architecture", "User Flows", "Journey Mapping", "Personas"
                ],
                tools: [
                    "Figma", "Sketch", "Adobe XD", "Axure",
                    "Balsamiq", "Optimal Workshop", "UserTesting", "Hotjar"
                ],
                learningResources: [
                    LearningResource(
                        title: "Don't Make Me Think",
                        type: .book,
                        author: "Steve Krug",
                        url: nil
                    ),
                    LearningResource(
                        title: "About Face: The Essentials of Interaction Design",
                        type: .book,
                        author: "Alan Cooper",
                        url: nil
                    )
                ],
                careerLevels: [
                    "Junior UX Designer",
                    "UX Designer",
                    "Senior UX Designer",
                    "Lead UX Designer",
                    "Principal UX Designer"
                ],
                salaryRange: "$60K - $160K+",
                demandLevel: .veryHigh
            ),
            
            // Interaction Designer
            DesignDiscipline(
                id: "interaction-design",
                name: "Interaction Designer",
                icon: "hand.tap",
                color: "#FCBAD3",
                description: "Designing how users interact with digital products",
                overview: """
                Interaction designers focus on creating engaging interfaces with well-thought-out behaviors. They design the interactive elements and micro-interactions that make products feel alive and responsive.
                
                ## Core Competencies
                - Interaction patterns
                - Micro-interactions
                - Animation principles
                - Gesture design
                - State management
                - Feedback systems
                - Prototyping
                
                ## Key Focus Areas
                - Button states and transitions
                - Loading and progress indicators
                - Form interactions
                - Navigation patterns
                - Gesture controls
                - Haptic feedback
                """,
                keySkills: [
                    "Interaction Patterns", "Micro-interactions", "Animation", "Prototyping",
                    "Gesture Design", "State Design", "Motion Design", "User Feedback"
                ],
                tools: [
                    "Figma", "Framer", "Principle", "ProtoPie",
                    "After Effects", "Origami Studio", "Flinto"
                ],
                learningResources: [],
                careerLevels: [
                    "Interaction Designer",
                    "Senior Interaction Designer",
                    "Lead Interaction Designer"
                ],
                salaryRange: "$65K - $150K+",
                demandLevel: .high
            ),
            
            // UX Researcher
            DesignDiscipline(
                id: "ux-research",
                name: "UX Researcher",
                icon: "chart.bar.doc.horizontal",
                color: "#A8D8EA",
                description: "Understanding user needs through research and data",
                overview: """
                UX researchers use various research methods to understand user behaviors, needs, and motivations. They provide insights that inform design decisions and product strategy.
                
                ## Research Methods
                
                ### Qualitative
                - User interviews
                - Contextual inquiry
                - Diary studies
                - Focus groups
                - Usability testing
                
                ### Quantitative
                - Surveys
                - Analytics analysis
                - A/B testing
                - Card sorting
                - Tree testing
                
                ## Core Competencies
                - Research planning
                - Data collection
                - Analysis and synthesis
                - Insight generation
                - Stakeholder communication
                """,
                keySkills: [
                    "User Interviews", "Usability Testing", "Surveys", "Data Analysis",
                    "Research Planning", "Synthesis", "Personas", "Journey Mapping"
                ],
                tools: [
                    "UserTesting", "Optimal Workshop", "Hotjar", "Maze",
                    "Dovetail", "Airtable", "Miro", "Google Analytics"
                ],
                learningResources: [
                    LearningResource(
                        title: "Just Enough Research",
                        type: .book,
                        author: "Erika Hall",
                        url: nil
                    )
                ],
                careerLevels: [
                    "UX Research Associate",
                    "UX Researcher",
                    "Senior UX Researcher",
                    "Lead UX Researcher",
                    "Principal UX Researcher"
                ],
                salaryRange: "$70K - $180K+",
                demandLevel: .veryHigh
            ),
            
            // UX Writer
            DesignDiscipline(
                id: "ux-writing",
                name: "UX Writer",
                icon: "text.bubble",
                color: "#FFD93D",
                description: "Crafting clear, concise copy for digital products",
                overview: """
                UX writers create the words that guide users through digital experiences. They write microcopy, error messages, onboarding flows, and help documentation that makes products easier to use.
                
                ## Core Competencies
                - Microcopy writing
                - Voice and tone
                - Content strategy
                - Information hierarchy
                - Accessibility
                - Localization
                - A/B testing copy
                
                ## Writing Principles
                - Clarity over cleverness
                - Consistency in voice
                - Conciseness
                - Conversational tone
                - Accessibility
                - Inclusive language
                """,
                keySkills: [
                    "Microcopy", "Voice & Tone", "Content Strategy", "Copywriting",
                    "Editing", "Localization", "Accessibility", "User Research"
                ],
                tools: [
                    "Figma", "Google Docs", "Grammarly", "Hemingway Editor",
                    "Frontitude", "Ditto", "Phrase"
                ],
                learningResources: [
                    LearningResource(
                        title: "Microcopy: The Complete Guide",
                        type: .book,
                        author: "Kinneret Yifrah",
                        url: nil
                    )
                ],
                careerLevels: [
                    "UX Writer",
                    "Senior UX Writer",
                    "Lead UX Writer",
                    "Content Design Lead"
                ],
                salaryRange: "$60K - $140K+",
                demandLevel: .high
            ),
            
            // Information Architect
            DesignDiscipline(
                id: "information-architecture",
                name: "Information Architect",
                icon: "square.grid.3x3.square",
                color: "#6BCB77",
                description: "Organizing and structuring information for optimal findability",
                overview: """
                Information architects organize and structure content and information in digital products. They create navigation systems, taxonomies, and hierarchies that help users find what they need.
                
                ## Core Competencies
                - Content inventory and audit
                - Taxonomy development
                - Navigation design
                - Site mapping
                - Card sorting
                - Tree testing
                - Search design
                
                ## Key Deliverables
                - Site maps
                - User flows
                - Taxonomies
                - Navigation systems
                - Content models
                - Wireframes
                """,
                keySkills: [
                    "Taxonomy", "Navigation Design", "Site Mapping", "Card Sorting",
                    "Content Strategy", "User Flows", "Search Design", "Metadata"
                ],
                tools: [
                    "Optimal Workshop", "Miro", "Figma", "XMind",
                    "Lucidchart", "Axure", "OmniGraffle"
                ],
                learningResources: [
                    LearningResource(
                        title: "Information Architecture for the World Wide Web",
                        type: .book,
                        author: "Peter Morville & Louis Rosenfeld",
                        url: nil
                    )
                ],
                careerLevels: [
                    "Information Architect",
                    "Senior Information Architect",
                    "Lead Information Architect"
                ],
                salaryRange: "$70K - $150K+",
                demandLevel: .medium
            ),
            
            // Motion Designer
            DesignDiscipline(
                id: "motion-design",
                name: "Motion Designer",
                icon: "waveform.path",
                color: "#FF6B9D",
                description: "Bringing designs to life through animation and motion",
                overview: """
                Motion designers create animations and motion graphics for digital products, marketing, and entertainment. They combine design principles with animation techniques to create engaging visual experiences.
                
                ## Core Competencies
                - Animation principles (12 principles)
                - Timing and easing
                - Storyboarding
                - 2D/3D animation
                - Compositing
                - Video editing
                - Sound design basics
                
                ## Animation Principles
                1. Squash and stretch
                2. Anticipation
                3. Staging
                4. Straight ahead & pose to pose
                5. Follow through & overlapping action
                6. Slow in and slow out
                7. Arc
                8. Secondary action
                9. Timing
                10. Exaggeration
                11. Solid drawing
                12. Appeal
                """,
                keySkills: [
                    "Animation", "Motion Graphics", "Storyboarding", "Video Editing",
                    "3D Animation", "Compositing", "Sound Design", "Timing"
                ],
                tools: [
                    "After Effects", "Cinema 4D", "Blender", "Principle",
                    "Lottie", "Rive", "Premiere Pro", "DaVinci Resolve"
                ],
                learningResources: [
                    LearningResource(
                        title: "The Animator's Survival Kit",
                        type: .book,
                        author: "Richard Williams",
                        url: nil
                    )
                ],
                careerLevels: [
                    "Motion Designer",
                    "Senior Motion Designer",
                    "Lead Motion Designer",
                    "Animation Director"
                ],
                salaryRange: "$55K - $130K+",
                demandLevel: .high
            ),
            
            // Lead Designer
            DesignDiscipline(
                id: "lead-designer",
                name: "Lead Designer",
                icon: "person.3",
                color: "#C44569",
                description: "Leading design teams and driving design excellence",
                overview: """
                Lead designers manage design teams, set design direction, and ensure quality across all design work. They balance hands-on design work with team leadership and stakeholder management.
                
                ## Core Responsibilities
                - Team leadership and mentorship
                - Design strategy and vision
                - Quality assurance
                - Stakeholder management
                - Process improvement
                - Hiring and team building
                - Cross-functional collaboration
                
                ## Leadership Skills
                - Team management
                - Mentorship and coaching
                - Strategic thinking
                - Communication
                - Conflict resolution
                - Decision making
                - Resource planning
                """,
                keySkills: [
                    "Leadership", "Mentorship", "Strategy", "Communication",
                    "Team Management", "Stakeholder Management", "Design Systems", "Process Design"
                ],
                tools: [
                    "All design tools", "Project management tools",
                    "Collaboration tools", "Analytics tools"
                ],
                learningResources: [
                    LearningResource(
                        title: "The Manager's Path",
                        type: .book,
                        author: "Camille Fournier",
                        url: nil
                    )
                ],
                careerLevels: [
                    "Lead Designer",
                    "Design Manager",
                    "Senior Design Manager",
                    "Director of Design"
                ],
                salaryRange: "$120K - $220K+",
                demandLevel: .high
            ),
            
            // Art Director
            DesignDiscipline(
                id: "art-director",
                name: "Art Director",
                icon: "star.circle",
                color: "#F8B500",
                description: "Defining and executing creative vision across projects",
                overview: """
                Art directors are responsible for the visual style and creative direction of projects. They lead creative teams, develop concepts, and ensure all visual elements align with the creative vision.
                
                ## Core Responsibilities
                - Creative direction
                - Concept development
                - Team leadership
                - Client presentations
                - Budget management
                - Quality control
                - Trend awareness
                
                ## Key Skills
                - Creative vision
                - Art direction
                - Team leadership
                - Presentation skills
                - Client management
                - Budget management
                - Trend forecasting
                """,
                keySkills: [
                    "Creative Direction", "Concept Development", "Team Leadership", "Presentation",
                    "Client Management", "Budget Management", "Visual Strategy", "Trend Analysis"
                ],
                tools: [
                    "Adobe Creative Suite", "Figma", "Keynote",
                    "Miro", "InVision", "Frame.io"
                ],
                learningResources: [],
                careerLevels: [
                    "Art Director",
                    "Senior Art Director",
                    "Associate Creative Director",
                    "Creative Director",
                    "Chief Creative Officer"
                ],
                salaryRange: "$80K - $180K+",
                demandLevel: .medium
            )
        ]
    }
    
    // MARK: - Design Resources
    
    private func createDesignResources() -> [DesignResource] {
        // Would load comprehensive resources
        []
    }
    
    private func createDesignTools() -> [DesignTool] {
        // Would load tool database
        []
    }
    
    private func createDesignPrinciples() -> [DesignPrinciple] {
        // Would load design principles
        []
    }
    
    private func createCareerPaths() -> [CareerPath] {
        // Would load career progression paths
        []
    }
}

// MARK: - Models

struct DesignDiscipline: Identifiable, Codable {
    let id: String
    let name: String
    let icon: String
    let color: String
    let description: String
    let overview: String
    let keySkills: [String]
    let tools: [String]
    let learningResources: [LearningResource]
    let careerLevels: [String]
    let salaryRange: String
    let demandLevel: DemandLevel
}

enum DemandLevel: String, Codable {
    case low = "Low"
    case medium = "Medium"
    case high = "High"
    case veryHigh = "Very High"
}

struct LearningResource: Codable {
    let title: String
    let type: ResourceType
    let author: String
    let url: String?
}

enum ResourceType: String, Codable {
    case book = "Book"
    case course = "Course"
    case article = "Article"
    case video = "Video"
    case podcast = "Podcast"
}

struct DesignResource: Identifiable, Codable {
    let id: String
    let title: String
    let type: ResourceType
    let disciplines: [String]
    let url: String
    let description: String
}

struct DesignTool: Identifiable, Codable {
    let id: String
    let name: String
    let category: String
    let description: String
    let url: String
    let pricing: String
}

struct DesignPrinciple: Identifiable, Codable {
    let id: String
    let name: String
    let description: String
    let examples: [String]
}

struct CareerPath: Identifiable, Codable {
    let id: String
    let discipline: String
    let levels: [CareerLevel]
}

struct CareerLevel: Codable {
    let title: String
    let yearsExperience: String
    let responsibilities: [String]
    let skills: [String]
    let salaryRange: String
}


// MARK: - Additional Models

struct UIDesignPattern: Identifiable {
    let id = UUID()
    let name: String
    let description: String
    let category: String
    let codeExample: String
    let useCases: [String]
}

struct DesignExample: Identifiable {
    let id = UUID()
    let title: String
    let description: String
    let code: String
    let category: String
}

struct DesignGuideline: Codable {
    let title: String
    let description: String
    let category: String
    let examples: [String]
    let dosList: [String]
    let dontsList: [String]
}

extension DesignGuideline: Identifiable {
    var id: String { title }
}
